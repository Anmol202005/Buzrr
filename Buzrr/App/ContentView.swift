//
//  ContentView.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI



struct ContentView: View {
    @Environment(GameClient.self) private var client
    @State private var code = ""

    var body: some View {
        Group {
            if client.isRestoring {
                ProgressView()
            } else if client.shouldShowIntro && !client.session.hasIdentity {
                SubView(
                    imageStrings: ["first", "second", "third", "forth"],
                    nextView: UsernameView(),
                    onFinish: { client.markIntroSeen() }
                )
            } else if !client.session.hasIdentity {
                UsernameView()
            } else if !client.isInRoom {
                RoomCode(code: $code, onBack: { client.changeProfile() })
            } else {
                GameFlow()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: client.session.hasIdentity)
        .animation(.easeInOut(duration: 0.2), value: client.isInRoom)
        .task { await client.restoreSession() }
    }
}


private struct GameFlow: View {
    @Environment(GameClient.self) private var client

    var body: some View {
        let socket = client.socket
        switch socket.phase {
        case .lobby:
            GameLobby(code: client.joinedGameCode ?? "", players: socket.players)

        case .starting:
            GameLobby(
                code: client.joinedGameCode ?? "",
                players: socket.players,
                isStarting: true
            )

        case .question:
            if socket.hasAnswered || socket.question == nil {
                AnswerSubmittedView()
            } else if let question = socket.question {
                LiveGameView(
                    question: question,
                    questionNumber: socket.qIndex + 1,
                    totalQuestions: max(socket.qCount, 1),
                    deadline: socket.deadline,
                    selectedOptionId: socket.selectedOptionId,
                    isSubmitting: client.isSubmittingAnswer,
                    onSubmit: { optionId in
                        Task { await client.submitAnswer(optionId: optionId) }
                    }
                )
            }

        case .reveal:
            revealScreen

        case .final, .ended:
            gameOverScreen
        }
    }



    @ViewBuilder
    private var revealScreen: some View {
        let socket = client.socket
        let options = socket.question?.options ?? []
        let counts = socket.reveal?.counts ?? []
        let total = max(counts.reduce(0, +), 1)
        let percentages = counts.map { Int((Double($0) / Double(total) * 100).rounded()) }
        let correctIndex = options.firstIndex { option in
            socket.reveal?.correctOptionIds.contains(option.id) ?? false
        }
        let selectedIndex = options.firstIndex { $0.id == socket.selectedOptionId }

        QuestionResultsView(
            questionTitle: socket.question?.title ?? "",
            options: options.map(\.title),
            percentages: percentages,
            selectedIndex: selectedIndex,
            correctIndex: correctIndex,
            isCorrect: socket.you?.isCorrect ?? (selectedIndex != nil && selectedIndex == correctIndex),
            leaderboard: socket.leaderboard,
            myPlayerId: client.session.playerId,
            yourResult: socket.you
        )
    }



    @ViewBuilder
    private var gameOverScreen: some View {
        let socket = client.socket
        let entries = socket.finalEntries.isEmpty ? socket.leaderboard : socket.finalEntries
        let myId = client.session.playerId
        let mine = entries.first { $0.playerId == myId }

        GameOverView(
            correctAnswers: socket.correctCount,
            totalQuestions: max(socket.qCount, socket.answeredCount, 1),
            score: mine?.score ?? socket.you?.totalScore ?? 0,
            time: socket.elapsedTimeString,
            position: mine?.rank ?? 0,
            entries: entries,
            myPlayerId: myId,
            onHome: { client.finishSession() }
        )
    }
}

#Preview {
    ContentView()
        .environment(GameClient())
}

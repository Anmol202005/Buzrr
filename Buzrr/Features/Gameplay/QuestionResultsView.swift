//
//  QuestionResultsView.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct QuestionResultsView: View {
    let questionTitle: String
    let options: [String]
    let percentages: [Int]
    let selectedIndex: Int?
    let correctIndex: Int?
    let isCorrect: Bool
    let leaderboard: [LiveLeaderboardEntry]
    let myPlayerId: String?

    let yourResult: AnswerResultPayload?


    private let maxBarHeight: CGFloat = 110

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {


                Text("Question Results")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .padding(.top, 8)
                    .padding(.bottom, 16)


                resultBanner
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)


                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        leaderboardSection
                            .frame(height: geometry.size.height * 0.5)
                        

                        histogramSection
                            .frame(height: geometry.size.height * 0.5)
                    }
                }
            }
        }
    }



    private var resultBanner: some View {
        HStack(spacing: 14) {

            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 42, height: 42)

                Image(systemName: isCorrect ? "checkmark" : "xmark")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(isCorrect ? .green : .red)
            }

            Text(isCorrect ? "Correct!" : "Incorrect!")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            if let points = yourResult?.score, points > 0 {
                Text("+\(points)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 74)
        .background(
            LinearGradient(
                colors: isCorrect
                    ? [
                        Color(red: 0.04, green: 0.72, blue: 0.40),
                        Color(red: 0.25, green: 0.78, blue: 0.52)
                    ]
                    : [
                        Color(red: 0.90, green: 0.20, blue: 0.20),
                        Color(red: 0.96, green: 0.35, blue: 0.35)
                    ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }



    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .center) {
                Text("Leaderboard")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.08, green: 0.13, blue: 0.28))

                Spacer()

                if let result = yourResult, let rank = result.rank {
                    HStack(spacing: 5) {
                        Text("You")
                        Text("\(result.totalScore.formatted()) pts")
                        Text("\u{00B7}")
                        Text("Rank #\(rank)")
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.button)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.button.opacity(0.08))
                    .clipShape(Capsule())
                }
            }

            LeaderboardView(entries: leaderboard, myPlayerId: myPlayerId)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
    }



    private var histogramSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            VStack(alignment: .leading, spacing: 2) {
                Text("Answer Distribution")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.08, green: 0.13, blue: 0.28))

                Text(questionTitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            histogram

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .background(Color.gray.opacity(0.03))
    }

    private var histogram: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(options.indices, id: \.self) { index in
                VStack(spacing: 6) {

                    Text("\(percentage(at: index))%")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(barColor(for: index))

                    RoundedRectangle(cornerRadius: 6)
                        .fill(barColor(for: index))
                        .frame(height: barHeight(for: index))
                        .frame(maxWidth: .infinity)

                    Text(options[index])
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(barColor(for: index))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .frame(height: 28, alignment: .top)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
            }
        }
    }



    private func percentage(at index: Int) -> Int {
        index < percentages.count ? percentages[index] : 0
    }

    private func barHeight(for index: Int) -> CGFloat {

        max(6, maxBarHeight * CGFloat(percentage(at: index)) / 100)
    }

    private func barColor(for index: Int) -> Color {

        if index == correctIndex {
            return Color(red: 0.05, green: 0.72, blue: 0.40)
        }


        if !isCorrect && index == selectedIndex {
            return Color(red: 0.95, green: 0.25, blue: 0.30)
        }


        return Color(red: 0.96, green: 0.48, blue: 0.56)
    }
}

#Preview {
    QuestionResultsView(
        questionTitle: "Which country is the home to the Eiffel Tower?",
        options: ["France", "Germany", "Italy", "Spain"],
        percentages: [78, 8, 6, 8],
        selectedIndex: 0,
        correctIndex: 0,
        isCorrect: true,
        leaderboard: LiveLeaderboardEntry.previews,
        myPlayerId: "1",
        yourResult: AnswerResultPayload(
            answered: true,
            optionId: "o1",
            isCorrect: true,
            score: 850,
            totalScore: 2400,
            rank: 1
        )
    )
}

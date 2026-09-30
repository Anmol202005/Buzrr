//
//  GameOverView.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct GameOverView: View {

    let correctAnswers: Int
    let totalQuestions: Int
    let score: Int
    let time: String
    let position: Int
    let entries: [LiveLeaderboardEntry]
    let myPlayerId: String?
    var onHome: () -> Void = {}

    @State private var showResults = false

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {


                ZStack {
                    Text("Game Over")
                        .font(.system(
                            size: 17,
                            weight: .bold,
                            design: .rounded
                        ))
                        .foregroundStyle(
                            Color(red: 0.08, green: 0.14, blue: 0.30)
                        )
                }
                .padding(.horizontal, 22)
                .padding(.top, 8)
                .padding(.bottom, 12)


                Spacer(minLength: 8)

                Image("champ")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .padding(.horizontal, 8)


                Text("Game Over!")
                    .font(.system(
                        size: 25,
                        weight: .bold,
                        design: .rounded
                    ))
                    .foregroundStyle(
                        Color(red: 0.06, green: 0.12, blue: 0.30)
                    )
                    .padding(.top, 4)

                Text("You finished \(position)\(ordinalSuffix(for: position))")
                    .font(.system(
                        size: 16,
                        weight: .medium,
                        design: .rounded
                    ))
                    .foregroundStyle(
                        Color(red: 0.38, green: 0.46, blue: 0.62)
                    )
                    .padding(.top, 7)


                HStack(spacing: 12) {

                    StatCard(
                        title: "Correct",
                        value: "\(correctAnswers)/\(totalQuestions)"
                    )

                    StatCard(
                        title: "Score",
                        value: score.formatted()
                    )

                    StatCard(
                        title: "Time",
                        value: time
                    )
                }
                .padding(.horizontal, 22)
                .padding(.top, 24)

                Spacer()


                Button {
                    showResults = true
                } label: {
                    Text("View Results")
                        .font(.system(
                            size: 16,
                            weight: .bold,
                            design: .rounded
                        ))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.38, green: 0.17, blue: 0.95),
                                    Color(red: 0.28, green: 0.08, blue: 0.85)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)


                Button(action: onHome) {
                    Text("Home")
                        .font(.system(
                            size: 16,
                            weight: .bold,
                            design: .rounded
                        ))
                        .foregroundStyle(
                            Color(red: 0.38, green: 0.20, blue: 0.90)
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                        .overlay {
                            RoundedRectangle(cornerRadius: 13)
                                .stroke(
                                    Color(red: 0.72, green: 0.66, blue: 0.95),
                                    lineWidth: 1.5
                                )
                        }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 18)
            }
        }
        .sheet(isPresented: $showResults) {
            NavigationStack {
                LeaderboardView(entries: entries, myPlayerId: myPlayerId)
                    .padding()
                    .navigationTitle("Final Standings")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showResults = false }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func ordinalSuffix(for number: Int) -> String {
        if number % 100 >= 11 && number % 100 <= 13 {
            return "th"
        }

        switch number % 10 {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }
}




struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(
                    size: 13,
                    weight: .medium,
                    design: .rounded
                ))
                .foregroundStyle(
                    Color(red: 0.45, green: 0.52, blue: 0.65)
                )

            Text(value)
                .font(.system(
                    size: 16,
                    weight: .bold,
                    design: .rounded
                ))
                .foregroundStyle(
                    Color(red: 0.10, green: 0.18, blue: 0.35)
                )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 72)
        .background(Color.gray.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.08), lineWidth: 1)
        }
    }
}

#Preview {
    GameOverView(
        correctAnswers: 8,
        totalQuestions: 10,
        score: 3000,
        time: "12:45",
        position: 2,
        entries: LiveLeaderboardEntry.previews,
        myPlayerId: "1"
    )
}

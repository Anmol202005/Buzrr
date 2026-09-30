//
//  AnswerSubmittedView.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct AnswerSubmittedView: View {
    @State private var currentDot = 0

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()


                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 112, height: 112)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.05, green: 0.75, blue: 0.40),
                                    Color(red: 0.00, green: 0.63, blue: 0.32)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 68, height: 68)

                    Image(systemName: "checkmark")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundStyle(.white)
                }


                Text("Answer Submitted!")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        Color(red: 0.06, green: 0.12, blue: 0.28)
                    )
                    .padding(.top, 24)


                Text("Waiting for results...")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(
                        Color(red: 0.55, green: 0.63, blue: 0.76)
                    )
                    .padding(.top, 10)


                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.button)
                            .frame(
                                width: 10,
                                height: 10
                            )
                            .scaleEffect(currentDot == index ? 1.25 : 0.8)
                            .opacity(currentDot == index ? 1 : 0.7)
                    }
                }
                .padding(.top, 48)

                Spacer()
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                currentDot = (currentDot + 1) % 3
            }
        }
    }
}

#Preview {
    AnswerSubmittedView()
}

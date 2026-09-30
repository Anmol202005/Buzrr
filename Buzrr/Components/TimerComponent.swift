//
//  TimerComponent.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct TimerComponent: View {
    let totalSeconds: Int
    let deadline: Date?

    @State private var remainingSeconds: Int

    init(seconds: Int, deadline: Date? = nil) {
        self.totalSeconds = max(seconds, 1)
        self.deadline = deadline
        let initial = deadline.map { max(0, Int($0.timeIntervalSinceNow.rounded(.up))) } ?? seconds
        self._remainingSeconds = State(initialValue: initial)
    }

    var body: some View {
        GeometryReader { geometry in
            let progress = min(1, max(0, CGFloat(remainingSeconds) / CGFloat(totalSeconds)))

            ZStack(alignment: .leading) {

                Capsule()
                    .fill(Color.gray.opacity(0.08))

                Capsule()
                    .fill(Color.button)
                    .frame(
                        width: geometry.size.width * progress
                    )

                HStack(spacing: 5) {
                    Image(systemName: "clock")
                        .font(.system(size: 11, weight: .bold))

                    Text(timeString)
                        .font(
                            .system(
                                size: 12,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
            }
        }
        .frame(height: 34)
        .task(id: deadline) {
            while remainingSeconds > 0 {
                try? await Task.sleep(for: .seconds(1))
                if let deadline {

                    remainingSeconds = max(0, Int(deadline.timeIntervalSinceNow.rounded(.up)))
                } else {
                    remainingSeconds -= 1
                }
            }
        }
    }

    private var timeString: String {
        String(
            format: "%02d:%02d",
            remainingSeconds / 60,
            remainingSeconds % 60
        )
    }
}

#Preview {
    TimerComponent(seconds: 30)
        .padding()
}

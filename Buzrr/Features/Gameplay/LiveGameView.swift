//
//  LiveGameView.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct LiveGameView: View {
    var question: PublicQuestion
    var questionNumber: Int
    var totalQuestions: Int
    var deadline: Date?
    var selectedOptionId: String?
    var isSubmitting: Bool
    var onSubmit: (String) -> Void


    private var mediaURL: URL? {
        guard let media = question.media, !media.isEmpty else { return nil }
        return URL(string: media)
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {



                ZStack {
                    Text("Live Game")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .center)

                    HStack {
                        Spacer()

                        Text("\(questionNumber)/\(totalQuestions)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)


                TimerComponent(seconds: question.timeOut, deadline: deadline)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)


                if let mediaURL {
                    AsyncImage(url: mediaURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()

                        case .failure:
                            Color.gray.opacity(0.15)
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundStyle(.secondary)
                                }

                        default:
                            Color.gray.opacity(0.1)
                                .overlay {
                                    ProgressView()
                                }
                        }
                    }
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)
                }


                Text(question.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.08, green: 0.12, blue: 0.22))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 16)


                VStack(spacing: 10) {
                    ForEach(question.options) { option in
                        AnswerButton(
                            text: option.title,
                            isSelected: selectedOptionId == option.id
                        ) {
                            guard !isSubmitting else { return }
                            onSubmit(option.id)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}



struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {

                ZStack {
                    Circle()
                        .stroke(
                            isSelected
                                ? Color.white.opacity(0.8)
                                : Color.gray.opacity(0.25),
                            lineWidth: 2
                        )
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                Text(text)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(
                        isSelected ? .white : Color(red: 0.18, green: 0.22, blue: 0.30)
                    )

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(
                isSelected
                    ? Color(red: 0.08, green: 0.72, blue: 0.42)
                    : Color.white
            )
            .clipShape(RoundedRectangle(cornerRadius: 27))
            .overlay {
                RoundedRectangle(cornerRadius: 27)
                    .stroke(
                        isSelected
                            ? Color.clear
                            : Color.gray.opacity(0.16),
                        lineWidth: 1.5
                    )
            }
            .shadow(
                color: .black.opacity(isSelected ? 0.03 : 0.02),
                radius: 3,
                y: 1
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LiveGameView(
        question: .previewQuestion,
        questionNumber: 1,
        totalQuestions: 10,
        deadline: Date().addingTimeInterval(30),
        selectedOptionId: nil,
        isSubmitting: false,
        onSubmit: { _ in }
    )
}

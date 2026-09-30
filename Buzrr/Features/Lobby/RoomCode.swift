//
//  RoomCode.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct RoomCode: View {

    @Environment(GameClient.self) private var client

    @Binding var code: String
    var onBack: (() -> Void)? = nil
    @State private var isJoining = false

    var body: some View {
        VStack(spacing: 0) {

            HStack {
                if let onBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.black.opacity(0.85))
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Back")
                }

                Spacer()

                Text("Join Game")
                    .font(.title2)
                    .fontDesign(.rounded)
                    .bold()

                Spacer()

                if onBack != nil {
                    Color.clear.frame(width: 40, height: 40)
                }
            }
            .padding(.top, 10)



            Image("code")
                .resizable()
                .scaledToFit()
                .frame(width: 300)
                .padding(.top, 50)

            Text("Enter Game Code")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.black.opacity(0.85))


            Text("Ask your host for the game code\nand join the room.")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 12)

            HStack {
                Text("Game Code")
                    .font(.system(size: 17, weight: .bold, design: .rounded))

                Spacer()
            }
            .padding(.top, 40)

            TextField("e.g. ABC123", text: $code)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .padding(.horizontal, 20)
                .frame(height: 65)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                }
                .padding(.top, 10)

            ButtonComponent(
                buttonText: isJoining ? "Joining..." : "Join Game",
                textColor: .white,
                backgroundColor: Color.button,
                borderColor: Color.button,
                action: join
            )
            .disabled(isJoining)
            .padding(.top, 28)

            if let message = client.errorMessage {
                Text(message)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }

            Spacer()
        }
        .padding(.horizontal, 30)
        .dismissKeyboardOnTap()
    }


    private func join() {
        guard !isJoining else { return }
        isJoining = true
        Task {
            await client.joinRoom(code: code)
            isJoining = false
        }
    }
}

#Preview {
    RoomCode(code: .constant(""))
        .environment(GameClient())
}

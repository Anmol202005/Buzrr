//
//  UsernameView.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct UsernameView: View {
    @Environment(GameClient.self) private var client

    @State private var name: String = ""
    @State private var selectedProfile: Int = 1
    @State private var isSubmitting = false

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {


            Spacer()
                .frame(height: 60)

            Text("What's your name?")
                .fontDesign(.rounded)
                .font(.title)
                .bold()
                .padding(.bottom, 10)
                .padding(.horizontal, 30)

            Text("This will be your display name\nin the games.")
                .foregroundStyle(.gray)
                .font(.body)
                .fontDesign(.rounded)
                .padding(.bottom, 40)
                .padding(.horizontal, 30)

            HorizontalImageView { id in
                selectedProfile = id
            }
            .padding(.bottom,10)

            NameInputView(name: $name)
                .padding(.bottom, 40)
                .padding(.horizontal, 30)

            ButtonComponent(
                buttonText: isSubmitting ? "Creating..." : "Continue",
                textColor: .white,
                backgroundColor: .button,
                borderColor: .button,
                action: submit
            )
            .disabled(isSubmitting)
            .padding(.horizontal, 30)

            if let message = client.errorMessage {
                Text(message)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
            }


            Spacer()


            HStack {
                Spacer()
                Image("username-asset")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
                Spacer()
            }
            .padding(.bottom, 40)

        }
        .dismissKeyboardOnTap()
    }


    private func submit() {
        guard !isSubmitting else { return }
        isSubmitting = true
        Task {
            await client.createGuest(
                name: name,
                profile: PlayerAvatar.serverValue(forIndex: selectedProfile)
            )
            isSubmitting = false
        }
    }
}

#Preview {
    UsernameView()
        .environment(GameClient())
}

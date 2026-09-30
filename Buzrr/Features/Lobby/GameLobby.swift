//
//  GameLobby.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct GameLobby: View {

    var code: String
    var players: [RosterPlayer]
    var isStarting: Bool = false

    var body: some View {
        VStack(spacing: 0) {

            Text("Game Lobby")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.top, 8)
                .padding(.bottom, 24)

            HStack(spacing: 8) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 13, weight: .semibold))

                Text(code)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.button)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(Color.button.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.bottom, 30)

            HStack {
                Text("Players (\(players.count))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.85))

                Spacer()
            }
            .padding(.bottom, 10)

            VerticalListView(players: players)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.button.opacity(0.08))
                        .frame(width: 52, height: 52)

                    Image("lobby")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(isStarting ? "Game starting..." : "Waiting for more players...")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.black.opacity(0.8))

                    Text(isStarting ? "Get ready!" : "Share the code with your friends")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.black.opacity(0.5))
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 110)
            .background(Color.button.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.bottom, 20)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    GameLobby(code: "ABC123", players: RosterPlayer.previews, isStarting: true)
}

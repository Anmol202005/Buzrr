//
//  LeaderboardView.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct LeaderboardView: View {
    let entries: [LiveLeaderboardEntry]
    let myPlayerId: String?

    var body: some View {
        if entries.isEmpty {
            VStack {
                Spacer()
                Text("No scores yet")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(entries) { entry in
                        LeaderboardRow(entry: entry, isYou: entry.playerId == myPlayerId)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

struct LeaderboardRow: View {
    let entry: LiveLeaderboardEntry
    let isYou: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text("\(entry.rank)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.38, green: 0.20, blue: 0.90))
                .frame(width: 20)

            Image(PlayerAvatar.assetName(forProfilePic: entry.profilePic))
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())

            Text(entry.name)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(red: 0.10, green: 0.18, blue: 0.35))
                .lineLimit(1)

            Spacer()

            Text("\(entry.score)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.10, green: 0.18, blue: 0.35))
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
        .background(isYou ? Color.button.opacity(0.08) : Color.gray.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 11))
    }
}

#Preview {
    LeaderboardView(entries: LiveLeaderboardEntry.previews, myPlayerId: "1")
        .padding()
}

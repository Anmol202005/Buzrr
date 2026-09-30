//
//  VerticalListView.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct VerticalListView: View {
    var players: [RosterPlayer]

    var body: some View {
        List(players) { player in
                HStack {
                    Image(PlayerAvatar.assetName(forProfilePic: player.profilePic))
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 10))
                        .padding(5)
                        .foregroundStyle(.button)
                        .opacity(player.connected ? 1 : 0.4)

                    Text(player.name)
                        .font(.system(size: 14))
                        .bold()

                    Spacer()

                    if !player.connected {
                        Text("away")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 50)
                .listRowInsets(EdgeInsets())
        }
        .scrollContentBackground(.hidden)
        .background(Color.white)
        .listStyle(.plain)


    }
}

#Preview {
    VerticalListView(players: RosterPlayer.previews)
}

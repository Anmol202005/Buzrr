//
//  HorizontalImageView.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct HorizontalImageView: View {
    var onSelectionChanged: ((Int) -> Void)? = nil

    @State private var selectedID: Int = 1
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20){
                ForEach(1...12, id: \.self){ id in
                    let imageTitle = "profile" + String(id)
                    Image(imageTitle)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay {
                                Circle()
                                    .stroke(
                                        selectedID == id ? Color.blue : Color.clear,
                                        lineWidth: 3
                                    )
                            }
                            .scaleEffect(selectedID == id ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: selectedID)
                            .onTapGesture {
                                selectedID = id
                                onSelectionChanged?(id)
                            }
                }
            }
            .frame(height: 150)
            .padding(.horizontal, 10)
        }
        .scrollIndicators(.hidden)
        .padding(20)
    }
}

#Preview {
    HorizontalImageView()
}

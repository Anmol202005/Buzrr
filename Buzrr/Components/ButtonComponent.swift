//
//  ButtonComponent.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct ButtonComponent: View {
    
    var buttonText: String
    var textColor: Color
    var backgroundColor: Color
    var borderColor: Color
    var imageName: String?
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 10) {
                
                if let imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                
                Text(buttonText)
                    .foregroundStyle(textColor)
                    .font(.headline)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(borderColor, lineWidth: 1.5)
            }
        }
        
    }
}

#Preview {
    ButtonComponent(
        buttonText: "Continue as Guest",
        textColor: .purple,
        backgroundColor: Color.purple.opacity(0.08),
        borderColor: Color.purple.opacity(0.15)
    )
}

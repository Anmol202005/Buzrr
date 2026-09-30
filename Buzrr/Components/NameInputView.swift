//
//  NameInputView.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct NameInputView: View {
    @Binding var name: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            TextField("Enter your name", text: $name)
                .padding(.horizontal, 18)
            
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: 1)
                .padding(.horizontal, 5)
            
            Text("e.g. @JohnDoe")
                .foregroundStyle(.gray)
                .padding(.horizontal, 18)
        }
        .frame(height: 90)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1.5)
        }
    }
}

#Preview {
    NameInputView(name: .constant(""))
        .padding(.horizontal, 20)
}

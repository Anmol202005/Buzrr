//
//  SubView.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

struct SubView<NextView: View>: View {
    var imageStrings : [String]
    var nextView :  NextView

    var onFinish: (() -> Void)? = nil
    
    @State var imageIndex = 0
    @State var showNext = false
    
    var body: some View {
        
        NavigationStack {
            ZStack(){
                Image(imageStrings[imageIndex])
                    .resizable()
                    .ignoresSafeArea()
                
                
                VStack {
                    Spacer()
                    
                    ZStack {
                        HStack {
                            Spacer()
                            
                            HStack {
                                ForEach(0..<imageStrings.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == imageIndex ? .white : .gray)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                if imageIndex < imageStrings.count - 1 {
                                    imageIndex += 1
                                } else {
                                    onFinish?()
                                    showNext = true
                                }
                            } label: {
                                Image(systemName: "arrow.right")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .frame(width: 50, height: 50)
                                    .background(.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    
                    
                }
            }
            .navigationDestination(isPresented: $showNext) {
                nextView
            }
        }
    }
}

#Preview {
    SubView(imageStrings: ["first", "second", "third", "forth"], nextView: UsernameView())
}

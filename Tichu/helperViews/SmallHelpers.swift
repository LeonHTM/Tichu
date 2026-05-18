//
//  SmallHelpers.swift
//  Tichu
//
//  Created by Leon on 25.04.2026.
//

import SwiftUI

//Used in NameSheet
@ViewBuilder
func requirementRow(
    text: String,
    isValid: Bool
) -> some View {
    
    HStack(spacing: 10) {
        
        Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
        
        Text(text)
        
        Spacer()
    }
    .foregroundStyle(isValid ? .green : .red)
}



func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "de_DE") // European style
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter.string(from: date)
}



import SwiftUI

struct ColorfulIconLabelStyle: LabelStyle {
    var color: Color
    var fontSize: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            configuration.icon
                .font(.system(size: fontSize))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(color)
                        // Top light gloss
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.45),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .blendMode(.overlay)
                            )
                        )
                        // Subtle glossy border
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.15),
                                            .clear,
                                            .clear,
                                            .white.opacity(0.15)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                        // Depth shadow (important for “app icon” feel)
                        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                )
        }
    }
}


struct offlineView: View{
    var body: some View{
        VStack(alignment:.center,spacing:10){
            
               
                Text("No Internet Connection").font(.title2).fontWeight(.bold)
            
 
       
                Text("Your Device is not connected to the internet. To connect, turn off Airplane Mode or connect to a Wi-Fi network.").foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal,40)
            
        
            
        }
        
    }
    static func offlineAlert() -> Alert {
        Alert(
            title: Text("No Internet Connection"),
            message: Text("Your Device is not connected to the internet."),
            dismissButton: .default(Text("OK"))
        )
    }
}



    


#Preview{ProfileView()}

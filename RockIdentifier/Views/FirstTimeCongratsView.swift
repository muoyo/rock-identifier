// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

/// Congratulations overlay for first rock identification
struct FirstTimeCongratsOverlay: View {
    @Binding var isVisible: Bool
    let rockName: String
    let onDismiss: (() -> Void)? // Callback for when user dismisses
    
    @State private var titleScale: CGFloat = 0.3
    @State private var titleOpacity: Double = 0
    @State private var messageOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var backgroundOpacity: Double = 0
    @State private var sparkleOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(backgroundOpacity * 0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissMessage()
                }
            
            // Main card
            VStack(spacing: 20) {
                // Decorative sparkles around the message
                HStack {
                    Image(systemName: "sparkle")
                        .font(.title2)
                        .foregroundColor(StyleGuide.Colors.citrineGold)
                        .opacity(sparkleOpacity)
                        .rotationEffect(.degrees(45))
                    
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .font(.title3)
                        .foregroundColor(StyleGuide.Colors.citrineGold)
                        .opacity(sparkleOpacity)
                    
                    Spacer()
                    
                    Image(systemName: "sparkle")
                        .font(.title2)
                        .foregroundColor(StyleGuide.Colors.citrineGold)
                        .opacity(sparkleOpacity)
                        .rotationEffect(.degrees(-45))
                }
                .padding(.horizontal, 30)
                
                // Congratulations title
                VStack(spacing: 8) {
                    Text("🎉 Congratulations! 🎉")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                    
                    Text("First Rock Identified!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(StyleGuide.Colors.emeraldGreen)
                        .opacity(titleOpacity)
                }
                
                // Personal message
                VStack(spacing: 12) {
                    Text("You've successfully identified your first rock:")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(messageOpacity)
                    
                    Text(rockName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(StyleGuide.Colors.emeraldGreen.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(StyleGuide.Colors.emeraldGreen.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .opacity(messageOpacity)
                    
                    Text("Welcome to the fascinating world of geology! Your rock collection journey begins now.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(messageOpacity)
                }
                .padding(.horizontal, 16)
                
                // Action button
                Button(action: {
                    dismissMessage()
                }) {
                    HStack {
                        Image(systemName: "arrowshape.right.fill")
                        Text("Continue Exploring")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                StyleGuide.Colors.emeraldGreen,
                                StyleGuide.Colors.emeraldGreen.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: StyleGuide.Colors.emeraldGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle())
                .opacity(buttonOpacity)
                .padding(.horizontal, 8)
                
                // Decorative bottom sparkles
                HStack {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(StyleGuide.Colors.citrineGold)
                        .opacity(sparkleOpacity)
                    
                    Spacer()
                    
                    Image(systemName: "sparkle")
                        .font(.caption)
                        .foregroundColor(StyleGuide.Colors.citrineGold)
                        .opacity(sparkleOpacity)
                        .rotationEffect(.degrees(30))
                    
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(StyleGuide.Colors.citrineGold)
                        .opacity(sparkleOpacity)
                }
                .padding(.horizontal, 40)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 32)
        }
        .onAppear {
            showMessage()
        }
    }
    
    private func showMessage() {
        // Background fade in
        withAnimation(.easeOut(duration: 0.3)) {
            backgroundOpacity = 1.0
        }
        
        // Title dramatic entrance
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            titleScale = 1.0
            titleOpacity = 1.0
        }
        
        // Message reveal
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            messageOpacity = 1.0
        }
        
        // Sparkles appear
        withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
            sparkleOpacity = 1.0
        }
        
        // Button appears
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.9)) {
            buttonOpacity = 1.0
        }
        
        // Auto-dismiss removed - let user control their celebration moment!
        // This gives them time to fully enjoy the achievement
    }
    
    private func dismissMessage() {
        withAnimation(.easeInOut(duration: 0.4)) {
            titleOpacity = 0
            messageOpacity = 0
            buttonOpacity = 0
            sparkleOpacity = 0
            backgroundOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isVisible = false
            // Call the dismissal callback for review prompt
            onDismiss?()
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct FirstTimeCongratsOverlay_Previews: PreviewProvider {
    static var previews: some View {
        FirstTimeCongratsOverlay(
            isVisible: .constant(true),
            rockName: "Amethyst",
            onDismiss: {
                print("Congratulations dismissed - perfect time for review prompt!")
            }
        )
    }
}

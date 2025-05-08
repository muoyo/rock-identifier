// Rock Identifier: Crystal ID
// Muoyo Okome
//

import SwiftUI

struct ProcessingView: View {
    @Binding var isVisible: Bool
    
    // Animation states
    @State private var rotationAngle: Double = 0
    @State private var glowOpacity: Double = 0.5
    @State private var hintIndex: Int = 0
    
    // Processing hints
    let hints = [
        "Analyzing mineral composition...",
        "Identifying crystal structure...",
        "Comparing with geological database...",
        "Checking physical properties...",
        "Determining rock type...",
        "Analyzing texture and cleavage...",
        "Matching with known specimens..."
    ]
    
    // Timer for rotating through hints
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Rock icon with glow effect
                ZStack {
                    // Glow effect
                    Image(systemName: "circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)
                        .opacity(glowOpacity)
                        .blur(radius: 20)
                    
                    // Rock crystal icon
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotationAngle))
                }
                .padding(40)
                
                // Circular progress spinner
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(rotationAngle))
                }
                
                // Processing text
                Text("Analyzing your specimen")
                    .font(.title2)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                
                // Hint text that rotates through different hints
                Text(hints[hintIndex])
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(height: 50)
                    .padding(.horizontal, 40)
                    .opacity(0.8)
                    .id(hintIndex) // Force view refresh when hint changes
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: hintIndex)
                
                // Cancel button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isVisible = false
                    }
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .onReceive(timer) { _ in
            // Rotate through hints
            withAnimation {
                hintIndex = (hintIndex + 1) % hints.count
            }
        }
        .onAppear {
            // Start animations
            withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowOpacity = 0.8
            }
            
            withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

struct ProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessingView(isVisible: .constant(true))
    }
}

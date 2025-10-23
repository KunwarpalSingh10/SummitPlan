//
//  goal_appApp.swift
//  goal app
//
//  Created by Kunwar Singh on 8/3/24.
//

import SwiftUI
@main
struct SummitPlan: App {
    @StateObject var listViewModel = ListViewModel()
    @StateObject var customListViewModel = CustomListViewModel()
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var habit: Bool = true
    @State private var noti: Bool = true
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ZStack {
                    newtab(selectedDate: $selectedDate, selectedTime: $selectedTime, habit: $habit, noti: $noti)
                        .environmentObject(listViewModel)
                        .environmentObject(customListViewModel)
                        .environmentObject(StreakViewModel())
                    
                    if isFirstLaunch {
                        IntroductionView(isFirstLaunch: $isFirstLaunch)
                            .onTapGesture {
                                // Dismiss the introduction on tap, but delay the state change
                                // This prevents the view from disappearing before the animation is complete
                            }
                            .transition(.opacity)
                    }
//                    VStack {
//                        Spacer()
//                        Button("Reset Introduction View") {
//                            isFirstLaunch = true // Reset the flag to trigger the introduction view
//                        }
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                    }
                }
                
            }
        }
    }
}

struct IntroductionView: View {
    @State private var isButtonPressed = false  // Track button press
    @State private var offsetY: CGFloat = 0     // Initial position of ZStack
    @Binding var isFirstLaunch: Bool

    var body: some View {
        ZStack {
            // Background that moves
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .offset(y: offsetY) // Apply offset to background as well
            
            VStack(spacing: 20) {
                // Summit/Goal Illustration
                Image(systemName: "mountain.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)

                // App Name
                Text("SummitPlan")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .padding(.bottom, 5)

                // Tagline
                Text("Climb to your goals with SummitPlan!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                // Call to Action Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        isButtonPressed = true
                        offsetY = 500  // Move the ZStack down by 500 points
                    }
                }) {
                    Text("Start Your Journey")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding()
            .offset(y: offsetY) // Apply offset to content (text, button, etc.)
        }
        .onChange(of: isButtonPressed) { newValue in
            if newValue {
                // Delay setting `isFirstLaunch` after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    // Ensure the animation completes before dismissing the view
                    withAnimation {
                        isFirstLaunch = false
                    }
                }
            }
        }
    }
}






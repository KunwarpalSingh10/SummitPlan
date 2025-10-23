//
//  Settings.swift
//  goal app
//
//  Created by Kunwar Singh on 9/25/24.
//

import SwiftUI
import StoreKit
import UserNotifications

import SwiftUI
import UserNotifications

struct Settings: View {
    @Environment(\.presentationMode) private var presentationMode
    let center = UNUserNotificationCenter.current()
    @Environment(\.requestReview) var requestReview
    @State private var isNotificationEnabled: Bool = false
    
    

    func checkNotificationSettings(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notifications permission: \(error.localizedDescription)")
            } else {
                print("Notifications permission granted: \(granted)")
            }
        }
    }
    
    func enableNotifications() {
            requestNotificationPermissions()
            // Schedule your notifications here
        }
        
        func disableNotifications() {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            print("Notifications disabled")
        }
    var body: some View {
        
        ZStack {
            Color.gray.opacity(0.1) // Set the background color to light gray
                .edgesIgnoringSafeArea(.bottom) // Only ignore bottom safe area
            VStack {
                List {
                    Section {
                        
                        Button("Contact me") {
                            if let url = URL(string: "https://sites.google.com/view/summitplan-contact/home") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                        ShareLink(item: URL(string: "https://apps.apple.com/us/app/summitplan/id6727003917")!) {
                            Text("Share")
                        }
                        Button("Review") {
                            requestReview()
                        }
                    } header: {
                        Text("About")
                            .foregroundStyle(.black)
                            .bold()
                            .textCase(nil)
                    }

                    
                    
                    
                }
                .foregroundStyle(.black)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true) // Disable scrolling
                .frame(height: 180) // Constrain height
//                .background(.black)

                

                
                List {
                    Section {
                        HStack {
                            Text("Notifications")
                            Spacer()
                            if isNotificationEnabled {
                                Text("ON")
                                    .bold()
                            }
                            else {
                                Text("OFF")
                                    .bold()
                            }
                        }
                        
                        Text("To enable/disable notifications, go to Settings > Notifications or press the button below")
                            .font(.subheadline)
                        
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                // Open Settings if notifications are disabled
                                if !isNotificationEnabled || isNotificationEnabled {
                                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(settingsURL)
                                    }
                                }
                                
                            }) {
                                Text("Manage Notifications")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: 300)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }
                        
                        
                        
                        
                    } header: {
                        Text("Notifications")
                            .foregroundStyle(.black)
                            .bold()
                            .textCase(nil)
                    }
                    .listRowSeparator(.hidden)
                    .onAppear {
                        checkNotificationSettings { isEnabled in
                            self.isNotificationEnabled = isEnabled
                        }
                    }
                    

                    
                    
                }
                .foregroundStyle(.black)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true) // Disable scrolling
                //                .frame(maxHeight: .infinity) // Constrain height
                

                
            }
            

            
 
            
        }
 
        .navigationBarTitle("Settings", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.black)
                            .bold()
                    }
                }
            }
        }
        
    }
    
}


struct Quote: Identifiable {
    let id = UUID()
    let text: String
    let author: String
}

struct Quotelook: View {
    // Data: Combined List of Quotes
    let quotes: [Quote] = [
        // First Set of Quotes
        Quote(text: "If life were predictable, it would cease to be life and be without flavor.", author: "Eleanor Roosevelt"),
        Quote(text: "In the end, it‘s not the years in your life that count. It’s the life in your years.", author: "Abraham Lincoln"),
        Quote(text: "Life is a succession of lessons which must be lived to be understood.", author: "Ralph Waldo Emerson"),
        Quote(text: "You will face many defeats in life, but never let yourself be defeated.", author: "Maya Angelou"),
        Quote(text: "Never let the fear of striking out keep you from playing the game.", author: "Babe Ruth"),
        Quote(text: "Life is never fair, and perhaps it is a good thing for most of us that it is not.", author: "Oscar Wilde"),
        Quote(text: "The only impossible journey is the one you never begin.", author: "Tony Robbins"),
        Quote(text: "In this life, we cannot do great things. We can only do small things with great love.", author: "Mother Teresa"),
        Quote(text: "Only a life lived for others is a life worthwhile.", author: "Albert Einstein"),
        Quote(text: "The purpose of our lives is to be happy.", author: "Dalai Lama"),
        Quote(text: "You may say I‘m a dreamer, but I’m not the only one. I hope someday you'll join us. And the world will live as one.", author: "John Lennon"),
        Quote(text: "You only live once, but if you do it right, once is enough.", author: "Mae West"),
        Quote(text: "To be yourself in a world that is constantly trying to make you something else is the greatest accomplishment.", author: "Ralph Waldo Emerson"),
        Quote(text: "Don't worry when you are not recognized but strive to be worthy of recognition.", author: "Abraham Lincoln"),
        Quote(text: "The greatest glory in living lies not in never falling, but in rising every time we fall.", author: "Nelson Mandela"),
        
        // New Set of Quotes (Without Numbers)
        Quote(text: "The secret of success is to do the common thing uncommonly well.", author: "John D. Rockefeller Jr."),
        Quote(text: "I find that the harder I work, the more luck I seem to have.", author: "Thomas Jefferson"),
        Quote(text: "Success is not final; failure is not fatal: It is the courage to continue that count.", author: "Winston S. Churchill"),
        Quote(text: "The way to get started is to quit talking and begin doing.", author: "Walt Disney"),
        Quote(text: "Don't be distracted by criticism. Remember — the only taste of success some people get is to take a bite out of you.", author: "Zig Ziglar"),
        Quote(text: "Success usually comes to those who are too busy to be looking for it.", author: "Henry David Thoreau"),
        Quote(text: "Everything you can imagine is real.", author: "Pablo Picasso"),
        Quote(text: "If you want to make your dreams come true, the first thing you have to do is wake up.", author: "J.M. Power"),
        Quote(text: "There are no secrets to success. It is the result of preparation, hard work, and learning from failure.", author: "Colin Powell"),
        Quote(text: "The real test is not whether you avoid this failure, because you won‘t. It’s whether you let it harden or shame you into inaction, or whether you learn from it; whether you choose to persevere.", author: "Barack Obama"),
        Quote(text: "The only limit to our realization of tomorrow will be our doubts of today.", author: "Franklin D. Roosevelt"),
        Quote(text: "It is better to fail in originality than to succeed in imitation.", author: "Herman Melville"),
        Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt")
    ]
    
    var body: some View {
        NavigationView {
            List(quotes) { quote in
                VStack(alignment: .leading, spacing: 8) {
                    Text("\"\(quote.text)\"")
                        .font(.body)
                        .foregroundColor(.primary)
                    Text("- \(quote.author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Famous Quotes")
        }
    }
}



struct HomeScreenOption: View {
    @State private var selectedSegment = 0
    private let segments = ["Classic", "Calender"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<segments.count, id: \.self) { index in
                Text(segments[index])
                    .fontWeight(.medium)
                    .foregroundColor(selectedSegment == index ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedSegment == index ? Color.black : Color(UIColor.systemGray4))
                    .cornerRadius(8)
                    .onTapGesture {
                        withAnimation {
                            selectedSegment = index
                        }
                    }
            }
        }
        .frame(height: 30)
        .background(Color(UIColor.systemGray5))
        .cornerRadius(8)
    }
}

#Preview {
    Settings()
}

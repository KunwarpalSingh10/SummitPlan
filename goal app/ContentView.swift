//
//  ContentView.swift
//  goal app
//
//  Created by Kunwar Singh on 8/3/24.
//

import SwiftUI


struct CategoryView: View {
    let title: String
    let activities: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .bold()
                .padding(.bottom, 10)
            
            ForEach(activities, id: \.self) { activity in
                NavigationLink(destination: Editor(activity: activity)) {
                    ActivityRow(activity: activity)
                }
            }
            .padding(.bottom, 10)
        }
    }
}





#Preview {
    ContentView()
}

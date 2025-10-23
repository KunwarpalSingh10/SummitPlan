//
//  MainScreen.swift
//  goal app
//
//  Created by Kunwar Singh on 8/3/24.
//

import SwiftUI
import Foundation



//
//  MainScreen.swift
//  goal app
//
//  Created by Kunwar Singh on 8/3/24.
//

import SwiftUI

struct MainScreen: View {
    @State var CreatePopup = false
    @State private var DeletePopup = false
    @State private var selectedOption: String?
    @State private var isGoalsBoxPresented = false
    @State private var tasks: [String] = []
    let name: String
    
    func deleteTask(at index: Int) {
        withAnimation {
            tasks.remove(at: index)
            selectedOption = ""
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack {
                // Display tasks
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(tasks.enumerated()), id: \.element) { index, task in
                            CreateGoalsBox(taskName: task, selectedOption: selectedOption, onDelete: { deleteTask(at: index) })
                                .transition(.slide)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if tasks.count == 0 {
                        ZStack(alignment: .center) {
                            Text("Plan Over Any Time")
                                .padding()
                                .transition(.slide)
                        }
                    }
                }
                
                if CreatePopup {
                    ZStack {
                        UserTab(isPresented: $CreatePopup, isPresentedGoal: $isGoalsBoxPresented, taskName: .constant(""), tasks: $tasks)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Menu {
                    Button("Create") {
                        selectedOption = "Create"
                        CreatePopup = true
                    }
                    Button("Delete") {
                        selectedOption = "Delete"
                        DeletePopup = true
                    }
                }
                label: {
                    RowView(iconName: "paintbrush", text: "Main Goals")
                        .padding()
                        .frame(height:0)
                }
            }
            .navigationTitle("Welcome, \(name)")
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CreateGoalsBox: View {
    @State private var isChecked: Bool = false
    var taskName: String
    var selectedOption: String?
    var onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(.gray)
                .frame(width: 375, height: 75)
                .padding(10)
                .shadow(radius: 5)
                .transition(.scale)
                .background(Color.white)
            HStack {
                Text("Task: " + taskName)
                    .padding(.leading, 30)
                Spacer()
                if selectedOption == "Delete" {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .padding(.trailing, 20)
                }
                Toggle("", isOn: $isChecked)
                    .toggleStyle(CheckBoxToggleStyle())
                    .padding(.trailing, 35)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct RowView: View {
    var iconName: String
    var text: String
    var showDivider = true
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: iconName)
            VStack(alignment: .leading) {
                Text(text)
                if showDivider {
                    
                } else {
                    Spacer()
                }
            }
        }
    }
}

struct UserTab: View {
    @Binding var isPresented: Bool
    @State private var MainNames: String = ""
    @Binding var isPresentedGoal: Bool
    @Binding var taskName: String // Add this binding
    @Binding var tasks: [String] // Add this binding
    
    var body: some View {
        VStack {
            Text("Create Goal")
                .font(.headline)
            TextField("Task: ", text: $MainNames)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Create") {
                tasks.append(MainNames) // Add task to the list
                isPresentedGoal = true
                isPresented = false
            }
            
            Button("Close") {
                isPresented = false
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .transition(.scale)
    }
}

struct CheckBoxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(configuration.isOn ? .blue : .black)
        }
    }
}

#Preview {
    NavigationStack {
        MainScreen(name: "John")
    }
}





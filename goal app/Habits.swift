//
//  Habits.swift
//  goal app
//
//  Created by Kunwar Singh on 1/5/25.
//

import SwiftUI

struct Habits: View {
    @EnvironmentObject var listViewModel: ListViewModel
    @Environment(\.presentationMode) private var presentationMode

    @EnvironmentObject var CustomListViewModel: CustomListViewModel
    var body: some View {
        let uniqueByName = Array(
            Dictionary(grouping: listViewModel.items.filter { $0.habit }, by: { $0.name })
                .compactMap { $0.value.first }
        )

        let uniqueByCategory = Array(
            Dictionary(grouping: listViewModel.items.filter { $0.habit }, by: { $0.category })
                .compactMap { $0.value.first }
        )

        // Combine the two lists and remove duplicates
        let combinedUniqueItems = Array(
            Dictionary(grouping: uniqueByName + uniqueByCategory, by: { $0.id })
                .compactMap { $0.value.first }
        )

//                    Color.gray.opacity(0.1) // Set the background color to light gray
//                        .edgesIgnoringSafeArea(.bottom) // Only ignore bottom safe area
            if (listViewModel.items.filter { $0.habit }.count) == 0 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("No Habits Created")
                            .bold()
                        Spacer()
                    }
                    Spacer()
                }
                    .bold()
                    .background(.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .navigationBarTitle("Habits", displayMode: .inline)
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
                    .environmentObject(listViewModel)
            
            } else {
                ScrollView {
                    VStack {
                        ForEach(combinedUniqueItems, id: \.id) { item in
                            taskView(for: item, screenWidth: 400)
                        }
                        .padding(.bottom, 10)
                        
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                }

                .background(.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                .navigationBarTitle("Habits", displayMode: .inline)
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
                .environmentObject(listViewModel)
            }
        
            
        Spacer()
            
    }
    
    
    func taskView(for item: ItemModel, screenWidth: CGFloat) -> some View {
        let isBackgroundDark = item.selectedColor.cgColor?.components?.reduce(0, +) ?? 0 < 2
        
        return RoundedRectangle(cornerRadius: 10)
            .fill(item.completion ? item.selectedColor.opacity(0.2) : item.selectedColor.opacity(1))
            .shadow(color: item.selectedColor.opacity(1), radius: 5)
            .overlay(
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(String(item.category.prefix(1)))
                                .font(.system(size: screenWidth * 0.12))
                            
                            
                            VStack(alignment: .leading) {
                                Spacer()
                                
                                Text(item.name.isEmpty ? String(item.category.dropFirst()) : item.name)
                                    .font(.system(size: screenWidth * 0.039))
                                    .foregroundColor(isBackgroundDark ? .white : .black)
                                
                                if !item.description.isEmpty {
                                    Text("  " + item.description)
                                        .foregroundColor(isBackgroundDark ? .white : .black)
                                        .font(.system(size: screenWidth * 0.03))
                                }
                                
//                                Text("  Time: \(formattedTime(from: item.selectedTime ?? Date()))")
//                                    .foregroundColor(isBackgroundDark ? .white : .black)
//                                    .font(.system(size: screenWidth * 0.03))
                                
                                Spacer()
                            }

                            Spacer()
                            ZStack {
                                Button(action: {
                                    // Add your button action here
                                    listViewModel.items.removeAll {
                                        ($0.name == item.name && $0.category == item.category) && $0.habit
                                    }
                                }, label: {
                                    Rectangle()
                                        .fill(Color.red) // Sets the background color of the Rectangle to red
                                        .cornerRadius(10)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: "trash")
                                                .foregroundStyle(.white) // Makes the trash icon white
                                        )
                                })


                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
            )
            .frame(width: screenWidth * 0.8, height: 60) // Adjust width and height as needed

    }
}




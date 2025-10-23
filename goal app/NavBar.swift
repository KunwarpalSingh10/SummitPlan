//
//  NavBar.swift
//  goal app
//
//  Created by Kunwar Singh on 11/2/24.
//

import SwiftUI

struct MainTabbedView: View {
    @EnvironmentObject var listViewModel: ListViewModel
    @State var selectedTab = 0
    @State private var isRectangleVisible = false
    @State private var isTrashcanVisible = false
    @Binding var selectedDate: Date
    @State var selectedTime: Date
    @State var habit: Bool
    @State var noti: Bool
    

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                GoalSet(selectedDate: $selectedDate, habit: habit, isRectangleVisible: $isRectangleVisible, isTrashcanVisible: $isTrashcanVisible)
                    .tag(0)
                    .environmentObject(listViewModel)

                Settings()
                    .tag(1)


            }
            .environmentObject(listViewModel)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if selectedTab == 0 {
                        Text(formattedMonthYear(from: selectedDate))
                            .font(.system(size: 25, weight: .bold))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(.leading, -4)
                            .foregroundStyle(.black)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if selectedTab == 0 {
                        HStack {
                            
                            Button(action: {
                                withAnimation {
                                    isRectangleVisible.toggle()
                                }
                            }) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
            }
            if selectedTab == 0 {
                BottomNav(selectedDate: $selectedDate, selectedTime: $selectedTime, habit: $habit, noti: $noti)
                    .transition(.scale(scale:0.3))
            }
            if selectedTab == 2 {
                BottomNav(selectedDate: $selectedDate, selectedTime: $selectedTime,habit: $habit, noti: $noti)
                    .transition(.scale(scale:0.3))
            }

            // Custom Tab Bar
            
            HStack {
                ForEach(TabbedItems.allCases, id: \.self) { item in
                    Button {
                        withAnimation {
                            selectedTab = item.rawValue
                        }
                    } label: {
                        CustomTabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue))
                    }
                }

            }
            .padding(6)
            .frame(height: 70)
            .background(Color.black.opacity(0.6))
            .cornerRadius(35)
            .padding(.horizontal, 26)

            // Show BottomNav only for Home Tab
            

        }
    }

    private func formattedMonthYear(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: date)
    }
}


enum TabbedItems: Int, CaseIterable {
//    case progression = 0
    case home
    case setting = 1
    
    var title: String {
        switch self {
//        case .progression:
//            return "Progression"
        case .home:
            return "Home"
        case .setting:
            return "Settings"
        }
    }
    
    var iconName: String {
        switch self {
//        case .progression:
//            return "chart.bar.fill"
        case .home:
            return "house"
        case .setting:
            return "gearshape"
        }
    }
}

extension MainTabbedView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()
            Image(systemName: imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .white : .gray)
                .frame(width: 20, height: 20)
            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .white : .gray)
            }
            Spacer()
        }
        .frame(width: isActive ? .infinity : 60, height: 60)
        .background(isActive ? Color.black.opacity(0.9) : .clear)
        .cornerRadius(30)
    }
}

struct BottomNav: View {
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var CustomListViewModel: CustomListViewModel
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    @Binding var habit: Bool
    @Binding var noti: Bool
    
    var body: some View {
        VStack {
            NavigationLink(destination: TaskAdding(selectedDate: $selectedDate, selectedTime: $selectedTime, habit: $habit, noti: $noti).environmentObject(listViewModel)
                .environmentObject(CustomListViewModel)) {
                    CurvedRectangle(cornerRadius: 30)
                        .overlay(
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 25)
                    .cornerRadius(25)
                    .foregroundColor(.white)
                )
                        .frame(width: 160, height: 60)
                        .foregroundStyle(Color.black.opacity(0.4))
                        .padding(.bottom,60)
            }
        }
    }
}

struct CurvedRectangle: Shape {
    var cornerRadius: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Move to the top left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        // Top-left curve
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)
        
        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        
        // Top-right curve
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(270),
                    endAngle: .degrees(0),
                    clockwise: false)
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // Left edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        path.closeSubpath()
        return path
    }
}



struct newtab: View {
    @State var selectedIndex = 0
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var CustomListViewModel: CustomListViewModel
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    @Binding var habit: Bool
    @Binding var noti: Bool

    @State private var isAnimating = false // Prevent rapid switching

    let icons = [
        "house",
        "plus",
        "calendar"
    ]

    var body: some View {
        GeometryReader { g in
            VStack {
                ZStack {
                    // Home View
                    if selectedIndex == 0 {
                        NavigationView {
                            VStack {
                                GoalSet(
                                    selectedDate: $selectedDate,
                                    habit: habit,
                                    isRectangleVisible: .constant(false),
                                    isTrashcanVisible: .constant(false)
                                )
                                .environmentObject(listViewModel)
                            }
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Text(formattedMonthYear(from: selectedDate))
                                        .font(.system(size: g.size.height * 0.035, weight: .bold))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .padding(.leading, -4)
                                        .foregroundStyle(.black)
                                }
                                ToolbarItem(placement: .topBarTrailing) {
                                    HStack {
                                        NavigationLink(destination: Habits()
                                            .environmentObject(listViewModel)
                                            .environmentObject(StreakViewModel())
                                        ) {
                                            Image("habitimg")
                                                .resizable()
                                                .foregroundColor(.black)
                                                .frame(width: 25, height: 25)
                                        }
                                        NavigationLink(destination: Settings()) {
                                            Image(systemName: "gear.circle.fill")
                                                .foregroundColor(.black)
                                                .environmentObject(listViewModel)
                                                .environmentObject(StreakViewModel())
                                        }
                                    }
                                }
                            }
                        }
                        .offset(x: selectedIndex == 0 ? 0 : g.size.width) // Slide from right
                        .zIndex(selectedIndex == 0 ? 1 : 0)
                    }

                    // Calendar View
                    if selectedIndex == 2 {
                        NavigationView {
                            VStack {
                                Calen(
                                    selectedDate: $selectedDate,
                                    noti: noti,
                                    isRectangleVisible: false
                                )
                            }
                        }
                        .offset(x: selectedIndex == 2 ? 0 : -g.size.width) // Slide from left
                        .zIndex(selectedIndex == 2 ? 1 : 0)
                    }
                }
                .animation(.spring(duration: 0.3), value: selectedIndex) // Linear animation for slide

//                .animation(.)
                // Bottom Tab Bar
                HStack {
                    ForEach(0..<3, id: \.self) { number in
                        Spacer()
                        if number == 1 {
                            NavigationLink(
                                destination: TaskAdding(
                                    selectedDate: $selectedDate,
                                    selectedTime: $selectedTime,
                                    habit: $habit,
                                    noti: $noti
                                )
                                .environmentObject(listViewModel)
                                .environmentObject(CustomListViewModel)
                            ) {
                                Image(systemName: icons[number])
                                    .font(.system(size: g.size.height * 0.035, weight: .regular, design: .default))
                                    .foregroundStyle(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.black)
                                    .cornerRadius(30)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                // Trigger haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            })
                        }else {
                            Button(action: {
                                guard !isAnimating else { return } // Prevent rapid switching
                                isAnimating = true

                                withAnimation(.linear(duration: 0.3)) { // Linear slide transition
                                    selectedIndex = number
                                }

                                // Delay to ensure smooth animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isAnimating = false
                                }

                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }) {
                                Image(systemName: icons[number])
                                    .font(.system(size: g.size.height * 0.035, weight: .regular, design: .default))
                                    .foregroundStyle(selectedIndex == number ? .black : Color(UIColor.lightGray))
                            }
                            .buttonStyle(NoHighlightButtonStyle())
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    private func formattedMonthYear(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: date)
    }

    struct NoHighlightButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 1.0 : 1.0) // No change on press
        }
    }
}






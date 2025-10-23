//
//  Progression.swift
//  goal app
//
//  Created by Kunwar Singh on 11/2/24.
//

import SwiftUI
import Charts

struct Progression: View {
    @StateObject private var viewModel = ListViewModel()
    let streakMessages: [String] = [
        "🔥 Day 0: Let’s get started! Every great journey starts with one step. 🚀",
        "🌟 Day 1: One day in! Keep the momentum going! 🎯",
        "⚡ Day 2: Two days strong! You're on a roll! 💪",
        "🏆 Day 3: Three days in, consistency is key! Keep it up! 🥳",
        "🚀 Day 4: Four days of greatness—your streak is taking off! 🌟",
        "🎉 Day 5: Five days straight! You're unstoppable! 🎯",
        "💥 Day 6: Six days strong—success loves consistency! 💎",
        "🔥 Day 7: One week in! 🔥 Your streak is on fire! Keep going! 💪",
        "🏅 Day 8: Eight days of dedication—you're crushing it! 🌟",
        "💪 Day 9: Nine days straight! Resilience pays off! 🚀",
        "🎯 Day 10: Ten days of consistency! Double digits! 🥳",
        "🌞 Day 11: Eleven days shining bright! You're doing amazing! 💥",
        "⚡ Day 12: Twelve days in—your streak is electrifying! ⚡",
        "🌟 Day 13: Thirteen days of focus! Luck favors the consistent! 🍀",
        "🚀 Day 14: Two weeks! Your momentum is unstoppable! 🔥",
        "💎 Day 15: Fifteen days—you're building a habit for success! 💪",
        "🎉 Day 16: Sixteen days strong—keep the streak alive! 🌟",
        "🏆 Day 17: Seventeen days! You’re on your way to greatness! 💥",
        "🔥 Day 18: Eighteen days—your progress is on fire! 🚀",
        "🌟 Day 19: Nineteen days of consistency! Keep soaring! 🎯",
        "🏅 Day 20: Twenty days in! You’re making it look easy! 🏆",
        "💥 Day 21: Three weeks! You’re crushing it daily! 🔥",
        "🎯 Day 22: Twenty-two days strong—amazing dedication! 💎",
        "🚀 Day 23: Twenty-three days—your streak is soaring! 🌟",
        "🔥 Day 24: Twenty-four days! You’re unstoppable! 💪",
        "🏆 Day 25: Twenty-five days—keep that energy up! 🎉",
        "🌟 Day 26: Twenty-six days of success! Keep pushing forward! 🚀",
        "💎 Day 27: Twenty-seven days—you’re building unstoppable habits! 💥",
        "⚡ Day 28: Four weeks strong! Amazing work so far! 🌞",
        "🎉 Day 29: Twenty-nine days—one more day to a full month! 🌟",
        "🏅 Day 30: One month complete! You’re incredible! 🔥",
        "🚀 Day 31: Day thirty-one—keep flying high! 🌟",
        "💥 Day 32: Thirty-two days of streak magic! 💎",
        "🎯 Day 33: Thirty-three days—you’re unstoppable! 💪",
        "🌞 Day 34: Day thirty-four—consistency is your superpower! ⚡",
        "🔥 Day 35: Five weeks strong! What a streak! 🏆",
        "💎 Day 36: Thirty-six days of greatness! 🌟",
        "🏆 Day 37: Day thirty-seven—another day of success! 💥",
        "🚀 Day 38: Thirty-eight days in—keep it rolling! 🎉",
        "🎯 Day 39: Day thirty-nine—almost at forty! 🔥",
        "🌟 Day 40: Forty days strong! Elite streak status! 💪",
        "💥 Day 41: Day forty-one—habits built, success earned! 🚀",
        "🎉 Day 42: Forty-two days! You’re doing amazing! 🌟",
        "🔥 Day 43: Day forty-three—keep that streak alive! 🎯",
        "🏅 Day 44: Forty-four days of dedication! You’re on fire! 💎",
        "💪 Day 45: Forty-five days—halfway to ninety! 🎉",
        "⚡ Day 46: Day forty-six—keep pushing forward! 🚀",
        "🌞 Day 47: Forty-seven days strong! You’re shining bright! 🌟",
        "🎯 Day 48: Day forty-eight—streak power in full force! 💥",
        "🔥 Day 49: Forty-nine days! Almost to fifty! 💪",
        "🏆 Day 50: Fifty days strong! Half a century of success! 🎉",
        "💎 Day 51: Day fifty-one—keep reaching new heights! 🚀",
        "🌟 Day 52: Fifty-two days—consistency in action! 🌞",
        "⚡ Day 53: Day fifty-three—you’re a streak legend! 🎯",
        "🔥 Day 54: Fifty-four days of greatness! 💥",
        "🏅 Day 55: Fifty-five days—what a commitment! 🌟",
        "🚀 Day 56: Eight weeks strong! Streaks create success! 🎉",
        "🎯 Day 57: Day fifty-seven—unstoppable momentum! 🔥",
        "🌟 Day 58: Fifty-eight days—keep shining bright! 💪",
        "💎 Day 59: Day fifty-nine—you’re almost at sixty! ⚡",
        "🏆 Day 60: Sixty days—two months of consistency! 🌞",
        "🔥 Day 61: Day sixty-one—you’re setting the standard! 🚀",
        "🎉 Day 62: Sixty-two days strong! Amazing progress! 💥",
        "💪 Day 63: Nine weeks of dedication—unstoppable! 🎯",
        "🌟 Day 64: Sixty-four days—you’re a streak star! 🌞",
        "⚡ Day 65: Sixty-five days of pure consistency! 🏅",
        "🔥 Day 66: Day sixty-six—habits that last a lifetime! 💎",
        "🚀 Day 67: Sixty-seven days strong—keep soaring! 🌟",
        "🎯 Day 68: Day sixty-eight—streak mastery in motion! 🔥",
        "🏆 Day 69: Sixty-nine days—you’re unstoppable! 🎉",
        "💥 Day 70: Seventy days—legendary streak power! 💪",
        "🌞 Day 71: Day seventy-one—habits are your superpower! 🚀",
        "⚡ Day 72: Seventy-two days—you’re still on fire! 🌟",
        "🔥 Day 73: Day seventy-three—streak goals achieved! 💎",
        "🎉 Day 74: Seventy-four days—keep that fire alive! 🎯",
        "🏅 Day 75: Seventy-five days! Three-quarters to 💯! 🌟",
        "🚀 Day 76: Day seventy-six—consistent success daily! 💥",
        "💪 Day 77: Seventy-seven days—you’re a streak legend! ⚡",
        "🔥 Day 78: Day seventy-eight—unstoppable progress! 🏆",
        "🌟 Day 79: Seventy-nine days—you’re almost there! 🎯",
        "💥 Day 80: Eighty days—success loves consistency! 🎉",
        "🚀 Day 81: Day eighty-one—keep reaching for 💯! 🌟",
        "🔥 Day 82: Eighty-two days—streak mastery in motion! 💎",
        "⚡ Day 83: Day eighty-three—you’re unstoppable! 🏅",
        "🏆 Day 84: Twelve weeks strong! Keep shining! 🎯",
        "🎉 Day 85: Eighty-five days—pure streak magic! 🚀",
        "🌟 Day 86: Day eighty-six—consistency is your key! 🔥",
        "💥 Day 87: Eighty-seven days—streak power in action! 🌞",
        "🔥 Day 88: Day eighty-eight—keep soaring high! 🏆",
        "🎯 Day 89: Eighty-nine days—you’re almost at 💯! 💪",
        "🚀 Day 90: Ninety days strong! Ten days to the top! 🌟",
        "🏆 Day 91: Day ninety-one—finish strong! 🔥",
        "💥 Day 92: Ninety-two days—unstoppable progress! 🌟",
        "🎉 Day 93: Day ninety-three—you’re streak royalty! 🚀",
        "⚡ Day 94: Ninety-four days—you're on the home stretch to 💯! 🌟",
        "🔥 Day 95: Ninety-five days strong! Just 5 more to hit the century mark! 🏆",
        "🚀 Day 96: Day ninety-six—you’re almost there, keep that fire burning! 💥",
        "🎯 Day 97: Ninety-seven days—consistency is your superpower! 💎",
        "🌟 Day 98: Day ninety-eight—just two days to 💯! You’ve got this! 🔥",
        "🏅 Day 99: Ninety-nine days—one more day to make history! 🚀",
        "💯 Day 100: 💯 ONE HUNDRED DAYS! 🎉 You’ve conquered the streak summit! Legendary effort! 🏆🔥"
    ]
    @State private var selectedSegment = 0
    private let segments = ["Today", "Overall"]
    @State var selectedDate: Date
    @State var habit: Bool
    @State var noti: Bool
    @EnvironmentObject var listViewModel: ListViewModel
    var body: some View {
        ScrollView {
            VStack(alignment:.leading) {
                
                
                //            HStack {
                //                Circle()
                //                    .frame(width:80, height:80)
                //                    .overlay(
                //                        Image("avatar")
                //                            .resizable()
                //                    )
                //                    .padding()
                //                    .shadow(radius: 5)
                //                Text("My Efficieny")
                //                    .font(.system(size:20))
                //
                //                Spacer()
                //            }
                //GraphView()
                TasksGraphView(viewModel: viewModel)
                    
                
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
                .padding()
                if selectedSegment == 0 {
                    Today()
                }
                else {
                   
                }
                
                
                GeometryReader { g in
                    VStack {
                        HStack{
                            //Streak
                            Rectangle()
                                .fill(.black)
                                .cornerRadius(15)
                                .padding(.leading, 15)
                                .frame(height: g.size.height * 0.45)
                            
                                .overlay(
                                    VStack {
                                        Text("Streak")
                                            .bold()
                                            .padding(.top, g.size.height * 0.05)
                                        Text("0")
                                            .padding()
                                            .bold()
                                            .font(.system(size: 36))
                                        Spacer()
                                        
                                    }
                                        .foregroundStyle(.white)
                                    
                                )
                            //Tasks completed
                            Rectangle()
                                .fill(.black)
                                .cornerRadius(15)
                                .padding(.trailing, 15)
                                .frame(height: g.size.height * 0.45)
                            
                                .overlay(
                                    VStack {
                                        Text("Tasks Completed")
                                            .bold()
                                            .padding(.top, g.size.height * 0.05)
                                        Text("0")
                                            .padding()
                                            .bold()
                                            .font(.system(size: 36))
                                        Spacer()
                                        
                                    }
                                        .padding(.trailing, g.size.width * 0.05)
                                        .foregroundStyle(.white)
                                    
                                )
                        }
                        HStack {
                            Rectangle()
                                .fill(.black)
                                .cornerRadius(15)
                                .padding(.leading, 15)
                                .frame(height: g.size.height * 0.45)
                                .overlay(
                                    VStack {
                                        Text("Streak")
                                            .bold()
                                            .padding(.top, g.size.height * 0.05)
                                        Text("0")
                                            .padding()
                                            .bold()
                                            .font(.system(size: 36))
                                        Spacer()
                                        
                                    }
                                        .foregroundStyle(.white)
                                    
                                )
                            
                            
                            Rectangle()
                                .fill(.black)
                                .cornerRadius(15)
                                .padding(.trailing, 15)
                                .frame(height: g.size.height * 0.45)
                                .overlay(
                                    VStack {
                                        Text("Tasks Completed")
                                            .bold()
                                            .padding(.top, g.size.height * 0.05)
                                        Text("0")
                                            .padding()
                                            .bold()
                                            .font(.system(size: 36))
                                        Spacer()
                                        
                                    }
                                        .padding(.trailing, g.size.width * 0.05)
                                        .foregroundStyle(.white)
                                    
                                )
                            
                        }
                    }
                }
                
                
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
    }
    
}

struct TasksGraphView: View {
    @ObservedObject var viewModel: ListViewModel
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    private var tasksByDay: [Int: Int] {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: selectedYear, month: selectedMonth)
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date) ?? 1..<31

        var counts = [Int: Int]()
        for day in range {
            counts[day] = 0
        }

        for task in viewModel.items {
            let taskDate = calendar.dateComponents([.year, .month, .day], from: task.selectedDate)
            if taskDate.year == selectedYear && taskDate.month == selectedMonth {
                counts[taskDate.day ?? 1, default: 0] += 1
            }
        }
        return counts
    }

    private let years = Array((Calendar.current.component(.year, from: Date()) - 10)...(Calendar.current.component(.year, from: Date()) + 10))

    var body: some View {
        VStack {
            // Month and Year Picker
            HStack(spacing: 8) {
                // Month Picker
                Picker("Month", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(Calendar.current.monthSymbols[month - 1])
                            .foregroundColor(.black) // Explicitly set text color to black
                            .tag(month)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
                
                // Year Picker
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text("\(year)")
                            .foregroundColor(.black) // Explicitly set text color to black
                            .tag(year)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
            }
            .padding()

            // Line Chart View
            Chart {
                ForEach(tasksByDay.keys.sorted(), id: \.self) { day in
                    LineMark(
                        x: .value("Day", day),
                        y: .value("Tasks", tasksByDay[day] ?? 0)
                    )
                    .foregroundStyle(.black)
                }
            }
            .chartXAxis {
                AxisMarks {
                    AxisGridLine().foregroundStyle(.white)
                    AxisTick().foregroundStyle(.white)
                    AxisValueLabel()
                        .foregroundStyle(.black)
                }
            }
            .chartYAxis {
                AxisMarks {
                    AxisGridLine().foregroundStyle(.black)
                    AxisTick().foregroundStyle(.black)
                    AxisValueLabel()
                        .foregroundStyle(.black)
                }
            }
            .chartXAxisLabel("Day of the Month")
                .foregroundStyle(.orange)
            .chartYAxisLabel("Number of Tasks", position: .leading)
                .foregroundStyle(.cyan)
            .frame(height: 300)
            .padding()

            Spacer()
        }
        .navigationTitle("Tasks Per Month")
        .foregroundColor(.white)
    }
}




//struct Today: View {
//    @EnvironmentObject var listViewModel: ListViewModel
//    @State private var progress: Double = 0.0
//    
//    var body: some View {
//        VStack {
//            CircularProgressBar(progress: progress)
//                .frame(width: 250, height: 250)
//        }
//        .onAppear {
//            // Fetch progress for today's tasks when the view appears
//            progress = listViewModel.progressForToday()
//        }
//        .onChange(of: listViewModel.items) { _ in
//            // Update progress when items change
//            progress = listViewModel.progressForToday()
//        }
//    }
//}


extension ListViewModel {
    func progressForToday() -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        let tasksForToday = items.filter { Calendar.current.isDate($0.selectedDate, inSameDayAs: today) }
        
        guard !tasksForToday.isEmpty else { return 0.0 }
        
        let completedTasks = tasksForToday.filter { $0.completion }
        return Double(completedTasks.count) / Double(tasksForToday.count)
    }
}





struct AllTime: View {
    @State private var progress: Double = 0.89
    var body: some View {
        VStack {
            CircularProgressView(progress: progress)
                .frame(width: 250, height: 250)
            
            // Slider to dynamically change progress for testing
            Slider(value: $progress, in: 0...1)
                .padding()
        }
        .onAppear {
            // Example to animate the progress
            withAnimation(.easeInOut(duration: 1.5)) {
                progress = 0.89
            }
        }
    }
}




struct CircularProgressView: View {
    var progress: Double // A value between 0 and 1 representing the progress
    
    // Computed property to determine the color based on the progress value
    private var progressColor: Color {
        switch progress {
        case ...0.4:
            return .red
        case 0.4...0.75:
            return .yellow
        default:
            return .green
        }
    }
    
    var body: some View {
        ZStack {
            // Background circle with shadow
            Circle()
                .stroke(lineWidth: 15)
                .opacity(0.3)
                .foregroundColor(progressColor)
                .shadow(color: progressColor.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Progress circle with shadow
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(progressColor)
                .rotationEffect(Angle(degrees: -90)) // Start from the top
                .shadow(color: progressColor.opacity(0.5), radius: 10, x: 0, y: 5)
                .animation(.linear, value: progress) // Smooth animation as progress changes
            
            // Text in the center
            VStack {
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                
                Text("of tasks completed")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
    }
}







import SwiftUI
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    func toHexa() -> String? {
        guard let components = self.cgColor?.components, components.count >= 3 else { return nil }
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        let rgb: Int = (Int(r * 255) << 16) | (Int(g * 255) << 8) | Int(b * 255)
        return String(format: "#%06x", rgb)
    }
}

struct Editor: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var CustomListViewModel: CustomListViewModel
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var isActive = false
    let activity: String
    @Binding var selectedDate: Date // Changed to Binding to allow updates
    @State private var selectedTime: Date
    @State private var habit: Bool
    @State private var noti: Bool

    init(activity: String, selectedDate: Binding<Date>, selectedTime: Binding<Date>, habit: Bool, noti: Bool) {
        self.activity = activity
        self._selectedDate = selectedDate
        // Initialize selectedTime with the current date and time
        self._selectedTime = State(initialValue: Date())
        self.habit = habit
        self.noti = noti
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.1) // Set the background color to light gray
                    .edgesIgnoringSafeArea(.bottom) // Only ignore bottom safe area
                Creating(activity: activity, selectedDate: $selectedDate, selectedTime: $selectedTime, habit: $habit, noti: $noti)
                    .environmentObject(listViewModel)
                    .environmentObject(CustomListViewModel)
                    .ignoresSafeArea(.keyboard)
                 
                
            }
            .ignoresSafeArea(.keyboard)
            .environmentObject(listViewModel)
            .environmentObject(CustomListViewModel)
            .navigationBarTitleDisplayMode(.inline)
            .background(.white)
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
                    .environmentObject(CustomListViewModel)
                }
                
                ToolbarItem(placement: .principal) {
                    Text(activity)
                        .font(.headline)
                        .foregroundStyle(.black)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .navigationBarBackButtonHidden(true)
        .environmentObject(CustomListViewModel)
    }
}

struct Creating: View {
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var CustomListViewModel: CustomListViewModel
    let activity: String
    @State private var navigateToDestination = false
    @State private var name: String
    @State private var description: String = ""
    @State private var selectedColor: Color = .black
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    @Binding var habit: Bool
    @Binding var noti: Bool
    @State private var isRectangleVisible: Bool = false
    @State private var isTrashcanVisible: Bool = false
    @State private var selectedOption = "1 Week"
    let options = ["1 Week", "2 Weeks", "1 Month", "3 Months", "1 Year"]

    let letter = ["M", "T", "W", "Th", "F", "Sa", "S"]
    @State private var buttonStates: [String: Bool] = [:]
    @State private var showPopover = false
    @State private var showPopup = false

    // Initializer
    init(activity: String, selectedDate: Binding<Date>, selectedTime: Binding<Date>, habit: Binding<Bool>, noti: Binding<Bool>) {
        self.activity = activity
        self._selectedDate = selectedDate
        self._selectedTime = selectedTime
        self._habit = habit
        self._noti = noti
        // Remove the first two letters from activity and initialize name
        let trimmedActivity = String(activity.dropFirst(2))
        _name = State(initialValue: trimmedActivity)
    }


    var body: some View {
        ZStack {
            GeometryReader { g in
                VStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Name")
                            .font(.headline)
                            .foregroundStyle(.black)
                        TextField("Ex. Morning Walk", text: $name)
                            .padding()
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .onChange(of: name) { newValue in
                                print("Text changed to: \(newValue)")
                            }
                    }
                    .ignoresSafeArea(.keyboard)
                    .padding(.horizontal, g.size.width * 0.04)
                    .padding(.top, g.size.height * 0.03)
                    .padding(.bottom, g.size.height * 0.02)
                    .foregroundStyle(.black)
                    .environmentObject(CustomListViewModel)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Description")
                            .font(.headline)
                            .foregroundStyle(.black)
                        
                        TextField("Ex. 30 Minutes", text: $description)
                            .padding()
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                    .ignoresSafeArea(.keyboard)
                    .padding(.horizontal, g.size.width * 0.04)
                    .padding(.top, g.size.height * 0.02)
                    .padding(.bottom, g.size.height * 0.02)
                    .foregroundStyle(.black)
                    .environmentObject(CustomListViewModel)
                    
                    
                    VStack {
                        ColorPicker("Choose a color", selection: $selectedColor)
                            .padding()
                            .foregroundColor(.black)
                            .bold()
                    }
                    .padding(.bottom, g.size.height * 0.02)
                    .environmentObject(CustomListViewModel)
                    
                    DatePicker(
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute, // Only show time selection (hours and minutes)
                        label: {
                            Text("Select a Time")
                                .bold() // Make the text bold
                                .foregroundStyle(.black)
                        }
                    )
                    .padding(.horizontal, g.size.width * 0.04)
                    .preferredColorScheme(.light)
                    .padding(.bottom, g.size.height * 0.03)
                    .environmentObject(CustomListViewModel)
                    
                    Toggle("Reminder", isOn: $noti)
                        .bold()
                        .frame(alignment:.top)
                        .padding(.horizontal, g.size.width * 0.04)
                        .padding(.bottom, g.size.height * 0.03)
                        .environmentObject(CustomListViewModel)
                    
                    Toggle("Habit Mode", isOn: $habit)
                        .bold()
                        .frame(alignment:.top)
                        .padding(.horizontal, g.size.width * 0.04)
                        .padding(.bottom, 0)
                        .environmentObject(CustomListViewModel)
                    
                    if habit {
                        ZStack {
                            Color.gray.opacity(0.1) // Set the background color to light gray
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.vertical)
                                .edgesIgnoringSafeArea(.bottom) // Only ignore bottom safe area
                            VStack {
                                HStack {
                                    Text("Duration:")
                                        .padding(.leading,g.size.width * 0.06)
                                    Picker("Choose an option", selection: $selectedOption) {
                                        ForEach(options, id: \.self) { option in
                                            Text(option)
                                            
                                        }
                                    }
                                    .accentColor(.black)
                                    .pickerStyle(MenuPickerStyle()) // Makes it look like a dropdown menu
                                    Spacer()
                                    
                                    
                                    
//                                    Button(action: {
//                                        showPopup.toggle()
//                                    }) {
//                                        Image(systemName: "info.circle.fill")
//                                            .font(.title)
//                                    }
//                                    .padding(.trailing, 30)
//
//                                    // Conditionally show the InfoPopup
//                                    if showPopup {
//                                        InfoPopup()
//                                            .frame(width: 300, height: 400)
//                                            .background(Color.white)
//                                            .cornerRadius(12)
//                                            .shadow(radius: 10)
//                                    }
                                    
                    
                                    
                                    
                                }
                                HStack {
                                    Spacer()
                                    ForEach(letter, id: \.self) { l in
                                        Button(action: {
                                            buttonStates[l, default: true].toggle()
                                        }) {
                                            Text(l)
                                                .foregroundColor(.white) // Text color
                                                .frame(maxWidth: .infinity, minHeight: g.size.height * 0.07) // Ensure the text fills the space
                                                .background(buttonStates[l, default: true] ? Color.black : Color.gray)
                                                .cornerRadius(10) // Rounded corners
                                        }
                                        
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .frame(width: g.size.width * 1, height: g.size.height * 0.2)
                    }
                    
                    
                    
                    Spacer()
                    
                    VStack {
                        Button(action: {
                            let selectedDays = letter.filter { buttonStates[$0, default: true] }
                            listViewModel.addItems(
                                category: activity,
                                name: name,
                                description: description,
                                selectedColor: selectedColor,
                                selectedDate: selectedDate,
                                selectedTime: selectedTime,
                                habit: habit,
                                noti: noti,
                                scheduled: true,
                                completion: true,
                                days: selectedDays,
                                duration: selectedOption // Pass the selected duration
                            )
                            navigateToDestination = true
                        }) {
                            Text("Submit")
                                .foregroundColor(adjustedTextColor(for: selectedColor))
                                .frame(width: 100, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedColor)
                                )
                        }
                        
                        
                        
                        .environmentObject(CustomListViewModel)
                    }
                    .ignoresSafeArea(.keyboard)
                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    NavigationLink(destination: newtab(selectedDate: $selectedDate, selectedTime: $selectedTime, habit: $habit, noti: $noti)
                        .navigationBarBackButtonHidden(true)
                        .environmentObject(listViewModel)
                        .environmentObject(CustomListViewModel)
                        .environmentObject(StreakViewModel()),
                                   isActive: $navigateToDestination) { // Or a button or some other trigger to navigate
                    }
                                   .navigationBarBackButtonHidden(true)
                                   .padding(.horizontal, 16)
                                   .padding(.bottom, 20)
                                   .environmentObject(CustomListViewModel)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .ignoresSafeArea(.keyboard)
                .environmentObject(CustomListViewModel)
            }
        }
        .ignoresSafeArea(.keyboard)
    }


    func getDate(for day: String) -> Date? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekdaySymbols = calendar.shortWeekdaySymbols // ["Sun", "Mon", "Tue", ...]

        guard let dayIndex = weekdaySymbols.firstIndex(where: { $0.prefix(2) == day.prefix(2) }) else {
            return nil // If the day does not match any weekday
        }

        let todayIndex = calendar.component(.weekday, from: today) - 1 // 0-based index
        let daysUntil = (dayIndex - todayIndex + 7) % 7 // Ensure positive offset

        return calendar.date(byAdding: .day, value: daysUntil, to: today)
    }

    func adjustedTextColor(for backgroundColor: Color) -> Color {
        let uiColor = UIColor(backgroundColor)
        var white: CGFloat = 0
        uiColor.getWhite(&white, alpha: nil)
        return white > 0.5 ? .black : .white
    }
}






//struct Editor_Previews: PreviewProvider {
//    static var previews: some View {
//        let listViewModel = ListViewModel()
//        Editor(activity: "Walk", selectedDate: .constant(Date()), selectedTime: .constant(Date()), priority: 0, noti: true) // Pass a binding for preview
//            .environmentObject(listViewModel)
//            .environmentObject(CustomListViewModel())
//    }
//}

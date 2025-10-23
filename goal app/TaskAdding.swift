import SwiftUI
import Combine

class UIEmojiTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setEmoji() {
        _ = self.textInputMode
    }
    
    override var textInputContextIdentifier: String? {
           return ""
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                self.keyboardType = .default // do not remove this
                return mode
            }
        }
        return nil
    }
}

struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    
    func makeUIView(context: Context) -> UIEmojiTextField {
        let emojiTextField = UIEmojiTextField()
        emojiTextField.placeholder = placeholder
        emojiTextField.text = text
        emojiTextField.delegate = context.coordinator
        return emojiTextField
    }
    
    func updateUIView(_ uiView: UIEmojiTextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextField
        
        init(parent: EmojiTextField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.text = textField.text ?? ""
            }
        }
    }
}

struct TaskAdding: View {
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var CustomListViewModel: CustomListViewModel
    @EnvironmentObject var SModel: StreakViewModel
    @State private var isDetailViewActive = false
    @State private var search = false
    @State private var create = false
    @State private var searched = ""
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    @Binding var habit: Bool
    @Binding var noti: Bool
    @State private var symbol = ""
    @State private var name = ""
    @State private var showError = false
    @State var tasksUpdated = true

    // Sample categories and activities
    @State private var categories = [
        ("Custom",[]),
        ("Health", ["🍉 Eat Fruits", "🥞 Eat Breakfast", "🥗 Eat Veges", "🌊 Drink Water", "😴 Sleep Earlier"]),
                ("Sports", ["🚶 Exercise", "🚶‍♀️ Walk", "🏃 Run", "🏊 Swim", "🚲 Cycle"]),
                ("Mind", ["🎓 Study", "📖 Reading Book", "💡 Isolation", "🧘 Meditation", "✍️ Journaling"]),
                ("Social", ["👫 Spend Time with Family", "🧑‍🤝‍🧑 Hang Out with Friends", "🎉 Attend a Party"]),
                ("Creativity", ["🎨 Painting", "🧶 Knitting", "📸 Photography", "🎭 Acting", "🎵 Composing Music"]),
                ("Leisure", ["🎮 Play Video Games", "📺 Watch a Movie", "🎧 Listen to Podcasts", "🌌 Stargazing"]),
                ("Finance", ["💰 Budgeting", "📈 Investing", "💳 Managing Credit", "💵 Saving Money"]),
                ("Travel", ["✈️ Plan a Trip", "🏕️ Go Camping", "🌍 Explore a New City", "🚗 Take a Road Trip"]),
                ("Education", ["📚 Attend a Workshop", "💻 Take Online Classes", "🎓 Complete a Certification"]),
                ("Home Improvement", ["🛠️ DIY Projects", "🌱 Gardening", "🧹 Decluttering", "🔧 Fixing Repairs"]),
                ("Personal Development", ["📖 Reading Self-Help Books", "🧠 Practicing Mindfulness", "📝 Setting Goals"]),
                // Additional Categories
                ("Wellness", ["🧘‍♀️ Yoga", "🌿 Aromatherapy", "🍵 Herbal Tea", "🧘‍♂️ Deep Breathing"]),
                ("Technology", ["💻 Coding", "📱 App Development", "🖥️ Building a Website", "🔌 Learning Networking"]),
                ("Family", ["👨‍👩‍👧 Family Outing", "📸 Family Photoshoot", "🍽️ Family Dinner", "🎉 Family Celebration"]),
                ("Environment", ["🌳 Plant a Tree", "♻️ Recycling", "🌱 Community Gardening", "🌼 Nature Walk"]),
                ("Hobbies", ["🎸 Playing an Instrument", "🧩 Puzzles", "🧶 Crafting", "🚀 Model Building"]),
                ("Community", ["🤝 Volunteer", "📅 Community Event", "🏙️ Local Exploration", "🛍️ Support Local Businesses"])
    ]
    

    // Filtered activities based on search input
    private func filteredActivities(for activities: [String]) -> [String] {
        if searched.isEmpty { return activities }
        return activities.filter { $0.localizedCaseInsensitiveContains(searched) }
    }

    var body: some View {
        ZStack {

            
            NavigationView {
                VStack(alignment: .leading) {
                
                    if search {
                            HStack {
                                Text("Search:")
                                    .bold()
                                TextField("Ex. Walk", text: $searched)
                                    .padding()
                                    .background(Color(.white))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                    .padding(.bottom, 8)
                            }
                            .padding(.top, 5)

                    }
                    ZStack {
                        Color.gray.opacity(0.1) // Set the background color to light gray
                            .edgesIgnoringSafeArea(.bottom) // Only ignore bottom safe area
                        ScrollView {
                            ForEach(filteredCategories(), id: \.0) { category in
                                CategoryView(
                                    title: category.0,
                                    activities: filteredActivities(for: category.1),
                                    selectedDate: $selectedDate,
                                    selectedTime: selectedTime,
                                    habit: habit,
                                    noti: noti
                                )
                                .padding(.horizontal)
                            }
                        }

                        
                    }
                    .foregroundColor(.black)
                    
                    .scrollIndicators(.hidden)
                    .edgesIgnoringSafeArea([.bottom])
                }
                .onAppear {
                    // Force the UI to update when the view appears
                    tasksUpdated = false
                }
                .onChange(of: CustomListViewModel.items) { _ in
                    // Trigger an update or refresh the UI after items change
                    tasksUpdated = true  // Example state update
                }


                .navigationTitle("New Task")
                .navigationBarTitleDisplayMode(.inline)
                .environmentObject(CustomListViewModel)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left").bold()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            Button(action: { search.toggle() }) {
                                Image(systemName: "magnifyingglass.circle.fill")
                            }
                            Button(action: { create.toggle() }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    
                }
                .environmentObject(CustomListViewModel)
            }
            .environmentObject(CustomListViewModel)
            .onChange(of: search) { newValue in
                if newValue == false {
                    searched = ""
                }
            }
            .navigationBarBackButtonHidden(true)
            .foregroundStyle(.black)
            .environmentObject(CustomListViewModel)
            
            // Overlay create box when create is true
            if create {
//                @State private var showError = false // Add this state variable

                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .shadow(radius: 10)
                    .frame(width: 300, height: 300)
                    .overlay(
                        VStack {
                            HStack {
                                Button(action: { create.toggle()
                                    showError = false}) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.black)
                                        .padding()

                                    Text("Custom Task")
                                        .font(.headline)
                                        .padding(.leading, 30)
                                }

                                Spacer()
                            }
                            .padding()

                            HStack {
                                Text("Choose Emoji: ")
                                EmojiTextField(text: $symbol, placeholder: "")

                                    .padding()
                                    .background(Color(.white))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                    .onReceive(Just(symbol)) { _ in limitText(1) }
                                    .frame(width: 60, height: 25)
                                    .padding(.leading, 3)

                                Spacer()
                            }
                            .padding(.bottom, 5)
                            .padding(.leading, 8)

                            // Fixed height for error message to avoid layout shifting
                            Text("Please choose an emoji.")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top,7)
                                .opacity(showError && symbol.isEmpty ? 1 : 0) // Show or hide
                                .frame(height: showError && symbol.isEmpty ? nil : 0) // Occupies space

                            HStack {
                                Text("Choose Name: ")
                                TextField("", text: $name)
                                    .padding()
                                    .background(Color(.white))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                Spacer()
                            }
                            .padding(.bottom, 5)
                            .padding(.leading, 8)

                            // Fixed height for error message to avoid layout shifting
                            Text("Please choose a name.")
                                .font(.caption)
                                .foregroundColor(.red)
                                
                                .opacity(showError && name.isEmpty ? 1 : 0) // Show or hide
                                .frame(height: showError && name.isEmpty ? nil : 0) // Occupies space

                            Spacer()

                            Button(action: {
                                if symbol.isEmpty || name.isEmpty {
                                    showError = true // Show error messages
                                } else {
                                    saveButton()// Trigger reload
                                    create.toggle()
                                    showError = false // Reset error state
                                    tasksUpdated = true
                                }
                            }) {
                                Text("Create")
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 50)
                                    .shadow(radius: 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(.black)
                                    )
                            }
                            .padding()
                        }
                    )
                    .transition(.scale)
                    .zIndex(1)

            }
            
            
        }
        .foregroundStyle(.black)
        .ignoresSafeArea(.keyboard)
        .environmentObject(StreakViewModel())
    }


    // New computed property to filter categories based on the search term
    private func filteredCategories() -> [(String, [String])] {
        // Map custom tasks from CustomListViewModel to "<symbol> <name>"
        let customTasks = CustomListViewModel.items.map { "\($0.symbol) \($0.name)" }
        
        // Update categories, including the "Custom" category with custom tasks
        let updatedCategories = categories.map { category in
            if category.0 == "Custom" {
                return (category.0, customTasks) // Use custom tasks from CustomListViewModel
            } else {
                return category
            }
        }
        
        // Filter based on search
        if searched.isEmpty {
            return updatedCategories
        }
        
        return updatedCategories.filter { category in
            // Check if any activity in the category matches the search term
            !filteredActivities(for: category.1).isEmpty
        }
    }




    func limitText(_ upper: Int) {
        if symbol.count > upper {
            symbol = String(symbol.prefix(upper))
        }
    }
    func saveButton() {
        // Add the new task to the CustomListViewModel
        CustomListViewModel.addItems(symbol: symbol, name: name)
        
        // Reset input fields after saving
        symbol = ""
        name = ""
    }







    @Environment(\.presentationMode) private var presentationMode
}



struct CategoryView: View {
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var CustomListViewModel: CustomListViewModel
    let title: String
    @State var activities: [String] // Changed to `@State` for local updates
    @Binding var selectedDate: Date
    @State var selectedTime: Date
    @State var habit: Bool
    @State var noti: Bool
    

    @State private var isExpanded = true // Controls dropdown state

    var body: some View {
        VStack(alignment: .leading) {
            DisclosureGroup(isExpanded: $isExpanded) {
                List {
                    ForEach(activities, id: \.self) { activity in
                        NavigationLink(
                            destination: Editor(
                                activity: activity,
                                selectedDate: $selectedDate,
                                selectedTime: $selectedTime,
                                habit: habit,
                                noti: noti
                            )
                            .environmentObject(listViewModel)
                            .environmentObject(CustomListViewModel)
                        ) {
                            ActivityRow(activity: activity)
                                .environmentObject(listViewModel)
                                .environmentObject(CustomListViewModel)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if title == "Custom" {
                                Button(role: .destructive) {
                                    deleteTask(activity: activity)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onChange(of: CustomListViewModel.items) { _ in
                            // Only update activities for the "Custom" category
                            if title == "Custom" {
                                activities = CustomListViewModel.items.map { "\($0.symbol) \($0.name)" }
                            }
                        }
                        .environmentObject(CustomListViewModel)
                        // Disable swipe-to-dismiss for non-custom tasks
                        .interactiveDismissDisabled(title != "Custom")
                        .environmentObject(CustomListViewModel)
                    
                    }
                }
                .listStyle(PlainListStyle()) // Optional: Customize list appearance
                .frame(height: CGFloat(activities.count) * 44) // Adjust height dynamically
                .cornerRadius(10)

            } label: {
                Text(title)
                    .bold()
                    .padding(.bottom, 10)
            }
       // Arrow color

            .onAppear {
                // Initial load of activities when the view appears
                updateActivities()
            }
            .onChange(of: CustomListViewModel.items) { _ in
                // Update activities whenever items in CustomListViewModel change
                updateActivities()
            }
            .environmentObject(CustomListViewModel)
            
            .tint(.black)
        }
        .environmentObject(CustomListViewModel)
    }
    
    private func updateActivities() {
        // Update activities only for the "Custom" category
        if title == "Custom" {
            activities = CustomListViewModel.items.map { "\($0.symbol) \($0.name)" }
        }
    }

    private func deleteTask(activity: String) {
        if let index = activities.firstIndex(of: activity) {
            activities.remove(at: index)
            if title == "Custom" {
                if let customIndex = CustomListViewModel.items.firstIndex(where: { "\($0.symbol) \($0.name)" == activity }) {
                    CustomListViewModel.items.remove(at: customIndex)
                }
            }
        }
    }
}



extension View {
    // Helper method to conditionally apply modifiers to the view
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}



struct ActivityRow: View {
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var CustomListViewModel: CustomListViewModel
    let activity: String
    
    var body: some View {
        HStack {
            Text(activity)
            Spacer()
            Text("")
        }
        .environmentObject(listViewModel)
        .environmentObject(CustomListViewModel)
    }
}

//#Preview {
//    TaskAdding(selectedDate: .constant(Date()), selectedTime: .constant(Date()), priority: Float(1)) // Use constant for preview
//        .environmentObject(ListViewModel())
//}


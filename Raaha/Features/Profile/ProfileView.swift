import MapKit
import SwiftUI

struct ProfileView: View {
    // MARK: - State
    @Environment(AppRouter.self) private var router
    @Environment(AdImpressionTracker.self) private var ads
    @State private var selectedCommuteModes: Set<String> = ["Bus"]
    @State private var selectedInterests: Set<String> = ["Beaches", "Heritage", "Food"]
    @State private var showLogoutDialog: Bool = false

    // Edit Profile state
    @State private var userName: String = "Akshaya Kumar"
    @State private var userEmail: String = "akshaya.kumar@gmail.com"
    @State private var userPhone: String = "+91 98765 43210"
    @State private var showEditSheet: Bool = false
    @State private var editingField: EditableField = .name
    @State private var editingPlace: SavedPlaceKind?
    @State private var homeLocation = FrequentLocation(
        address: "Chennai Central, Park Town",
        floor: "",
        landmark: "",
        latitude: 13.0827,
        longitude: 80.2755
    )
    @State private var workLocation = FrequentLocation(
        address: "T. Nagar Smart City Complex",
        floor: "",
        landmark: "",
        latitude: 13.0418,
        longitude: 80.2341
    )

    enum EditableField {
        case name, email, phone
        var title: String {
            switch self {
            case .name:  return "Full Name"
            case .email: return "Email Address"
            case .phone: return "Phone Number"
            }
        }
        var symbol: String {
            switch self {
            case .name:  return "person.fill"
            case .email: return "envelope.fill"
            case .phone: return "phone.fill"
            }
        }
        var keyboardType: UIKeyboardType {
            switch self {
            case .name:  return .default
            case .email: return .emailAddress
            case .phone: return .phonePad
            }
        }
    }

    private let commuteModes: [(name: String, symbol: String, customAsset: String?)] = [
        ("Bike", "bicycle", "icon_bike"),
        ("Auto", "car.fill", "icon_auto"),
        ("Cab", "car.fill", nil),
        ("Bus", "bus.fill", nil),
        ("Local Train", "train.side.front.car", "icon_train"),
        ("Metro", "train.side.front.car", "icon_metro")
    ]

    private let interests: [(name: String, symbol: String)] = [
        ("Beaches", "beach.umbrella"),
        ("Mountains", "mountain.2"),
        ("Heritage", "building.columns"),
        ("Food", "fork.knife"),
        ("Adventure", "tent.fill"),
        ("Nature", "leaf")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Top card from ExploreView (NavyHeader)
            header

            ScrollView {
                VStack(spacing: 16) {
                    // 0. Edit Profile Details
                    editProfileSection

                    // 1. Commute Preferences Group
                    commutePreferencesSection

                    // 2. Saved Chennai Places Group
                    savedPlacesSection

                    // 3. Discovery Interests Group
                    travelInterestsSection

                    // 4. Sponsored discovery preference
                    sponsoredDiscoverySection

                    // 5. Transit & Support Group
                    transitSupportSection

                    // Version Footer
                    footerNote
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .contentMargins(.bottom, 20, for: .scrollContent)
        }
        .raahaScreenBackground()
        .navyHeaderChrome()
        .confirmationDialog(
            "Log out of RAAHA?",
            isPresented: $showLogoutDialog,
            titleVisibility: .visible
        ) {
            Button("Log Out", role: .destructive) {
                router.logout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will need to sign in again to sync your journeys.")
        }
        .sheet(isPresented: $showEditSheet) {
            EditFieldSheet(
                field: editingField,
                userName: $userName,
                userEmail: $userEmail,
                userPhone: $userPhone
            )
            .presentationDetents([.height(260)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
        .sheet(item: $editingPlace) { kind in
            FrequentLocationEditor(
                title: kind.title,
                place: binding(for: kind)
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
    }

    private func binding(for kind: SavedPlaceKind) -> Binding<FrequentLocation> {
        switch kind {
        case .home: return $homeLocation
        case .workplace: return $workLocation
        }
    }

    // MARK: - Header (Top card from ExploreView / NavyHeader)
    private var header: some View {
        NavyHeader {
            VStack(alignment: .leading, spacing: 14) {
                Text("Profile")
                    .font(.raahaTitle)
                    .foregroundStyle(Color.white)
                    .accessibilityAddTraits(.isHeader)

                HStack(spacing: 16) {
                    // Profile Avatar with verified badge
                    ZStack(alignment: .bottomTrailing) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .foregroundStyle(Color.lightSkyBlue)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                            .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 2))

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.brightBlue, Color.electricBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 22, height: 22)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.white)
                            )
                            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                            .offset(x: 2, y: 2)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(userName)
                            .font(.raahaTitle2)
                            .foregroundStyle(Color.white)

                        Text(userEmail)
                            .font(.raahaCaption)
                            .foregroundStyle(Color(hex: 0xBDD8E9))

                        // Trips Taken Pill Badge
                        HStack(spacing: 6) {
                            Image(systemName: "bus.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color(hex: 0x2A90D4))

                            Text("25")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color(hex: 0x2A90D4))

                            Text("Trips Taken")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color.midnightBlue.opacity(0.75))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4.5)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        )
                        .padding(.top, 2)
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: - Edit Profile Section
    private var editProfileSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Personal Details")

            VStack(spacing: 0) {
                editRow(field: .name, value: userName)

                HairlineDivider(color: Color(hex: 0x49769F).opacity(0.12))

                editRow(field: .email, value: userEmail)

                HairlineDivider(color: Color(hex: 0x49769F).opacity(0.12))

                editRow(field: .phone, value: userPhone)
            }
            .padding(.horizontal, 14)
            .profileCard(radius: 24)
        }
    }

    private func editRow(field: EditableField, value: String) -> some View {
        Button {
            editingField = field
            showEditSheet = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: field.symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x2A90D4))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color(hex: 0x2A90D4).opacity(0.10))
                            .background(.ultraThinMaterial, in: Circle())
                    )
                    .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(field.title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: 0x49769F))

                    Text(value)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.midnightBlue)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "pencil")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: 0x2A90D4))
            }
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Commute Preferences Section
    private var commutePreferencesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Commute Preferences")

            VStack(alignment: .leading, spacing: 12) {
                Text("Select your preferred Chennai transit options:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: 0x49769F))

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                    spacing: 8
                ) {
                    ForEach(commuteModes, id: \.name) { item in
                        modeChip(item.name, symbol: item.symbol, customAsset: item.customAsset)
                    }
                }
            }
            .padding(14)
            .profileCard(radius: 24)
        }
    }

    private func modeChip(_ name: String, symbol: String, customAsset: String?) -> some View {
        let isSelected = selectedCommuteModes.contains(name)
        let mode = TransportMode.mode(for: name)
        let modeColor = mode?.color ?? Color.steelBlue

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                if isSelected {
                    selectedCommuteModes.remove(name)
                } else {
                    selectedCommuteModes.insert(name)
                }
            }
        } label: {
            HStack(spacing: 6) {
                if let customAsset {
                    Image(customAsset)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                } else {
                    Image(systemName: symbol)
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(name)
                    .font(.system(size: 13, weight: isSelected ? .bold : .semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.white : modeColor)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(
                Capsule()
                    .fill(
                        isSelected
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [Color.brightBlue, Color.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        : AnyShapeStyle(Color.white.opacity(0.85))
                    )
                    .background(.ultraThinMaterial, in: Capsule())
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.white.opacity(0.55) : Color.white.opacity(0.90), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? Color.electricBlue.opacity(0.35) : Color.black.opacity(0.04),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Saved Places Section
    private var savedPlacesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Frequent Locations")

            VStack(spacing: 0) {
                placeRow(
                    symbol: "house.fill",
                    title: "Home",
                    detail: homeLocation.detail,
                    color: Color(hex: 0x4EA8DE)
                ) {
                    editingPlace = .home
                }
                HairlineDivider(color: Color(hex: 0x49769F).opacity(0.12))
                placeRow(
                    symbol: "briefcase.fill",
                    title: "Workplace",
                    detail: workLocation.detail,
                    color: Color(hex: 0x2A82BE)
                ) {
                    editingPlace = .workplace
                }
            }
            .padding(.horizontal, 14)
            .profileCard(radius: 24)
        }
    }

    private func placeRow(symbol: String, title: String, detail: String, color: Color, edit: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: symbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.midnightBlue)

                Text(detail)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: 0x49769F))
                    .lineLimit(2)
            }

            Spacer()

            Button(action: edit) {
                Text("Edit")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x2A90D4))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.85))
                            .background(.ultraThinMaterial, in: Capsule())
                    )
                    .overlay(Capsule().stroke(Color.white.opacity(0.9), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Discovery Interests Section
    private var travelInterestsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Discovery Interests")

            VStack(alignment: .leading, spacing: 12) {
                Text("Customize your Chennai Explore recommendations:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: 0x49769F))

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                    spacing: 8
                ) {
                    ForEach(interests, id: \.name) { item in
                        interestChip(item.name, symbol: item.symbol)
                    }
                }
            }
            .padding(14)
            .profileCard(radius: 24)
        }
    }

    private func interestChip(_ name: String, symbol: String) -> some View {
        let isSelected = selectedInterests.contains(name)
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                if isSelected {
                    selectedInterests.remove(name)
                } else {
                    selectedInterests.insert(name)
                }
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : Color(hex: 0x2A90D4))

                Text(name)
                    .font(.system(size: 12, weight: isSelected ? .bold : .semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.white : Color.midnightBlue)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(
                Capsule()
                    .fill(
                        isSelected
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [Color.brightBlue, Color.electricBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        : AnyShapeStyle(Color.white.opacity(0.85))
                    )
                    .background(.ultraThinMaterial, in: Capsule())
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.white.opacity(0.55) : Color.white.opacity(0.90), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? Color.electricBlue.opacity(0.35) : Color.black.opacity(0.04),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Sponsored discovery
    private var sponsoredDiscoverySection: some View {
        @Bindable var tracker = ads
        return VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Sponsored discovery")

            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $tracker.sponsoredDiscoveryEnabled) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Show sponsored discovery")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.midnightBlue)
                        Text("Turns sponsored events and place placements on or off. Samples stay labelled, and hiding one placement keeps it hidden on this device.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(hex: 0x49769F))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .tint(Color(hex: 0x176487))
            }
            .padding(14)
            .profileCard(radius: 24)
        }
    }

    // MARK: - Transit & Support Section
    private var transitSupportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title: "Transit & Support")

            VStack(spacing: 0) {
                actionRow(
                    symbol: "questionmark.circle.fill",
                    title: "Chennai Transit FAQs and Help",
                    trailing: "Guide"
                )

                HairlineDivider(color: Color(hex: 0x49769F).opacity(0.12))

                Button {
                    showLogoutDialog = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                            .font(.raahaSubheadlineMedium)
                            .foregroundStyle(Color.strawberry)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color.strawberry.opacity(0.15))
                                    .background(.ultraThinMaterial, in: Circle())
                            )

                        Text("Logout")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.strawberry)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.raahaCaption)
                            .foregroundStyle(Color(hex: 0x49769F).opacity(0.5))
                    }
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .profileCard(radius: 24)
        }
    }

    private func actionRow(symbol: String, title: String, trailing: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.raahaSubheadlineMedium)
                .foregroundStyle(Color(hex: 0x2A90D4))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .background(.ultraThinMaterial, in: Circle())
                )
                .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 1))

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.midnightBlue)

            Spacer()

            Text(trailing)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: 0x49769F))

            Image(systemName: "chevron.right")
                .font(.raahaCaption)
                .foregroundStyle(Color(hex: 0x49769F).opacity(0.5))
        }
        .padding(.vertical, 10)
    }

    // MARK: - Section Title Helper
    private func sectionTitle(title: String) -> some View {
        Text(title)
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundStyle(Color.midnightBlue)
            .padding(.leading, 4)
    }

    // MARK: - Footer Note
    private var footerNote: some View {
        VStack(spacing: 4) {
            Text("RAAHA Chennai • Multimodal Urban Transit")
                .font(.raahaCaption)
                .foregroundStyle(Color(hex: 0x6B7280))
            Text("Version 1.0.0 (Build 50) • Native SwiftUI")
                .font(.raahaCaption2)
                .foregroundStyle(Color(hex: 0x6B7280))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

// MARK: - Edit Field Sheet
struct EditFieldSheet: View {
    let field: ProfileView.EditableField
    @Binding var userName: String
    @Binding var userEmail: String
    @Binding var userPhone: String

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    private var binding: Binding<String> {
        switch field {
        case .name:  return $userName
        case .email: return $userEmail
        case .phone: return $userPhone
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            Capsule()
                .fill(Color(hex: 0xC7D6E3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 18) {
                // Title row
                HStack(spacing: 10) {
                    Image(systemName: field.symbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x2A90D4))
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color(hex: 0x2A90D4).opacity(0.10))
                        )

                    Text("Edit \(field.title)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.midnightBlue)

                    Spacer()

                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x2A90D4))
                }

                // Text field
                HStack(spacing: 10) {
                    TextField(field.title, text: binding)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.midnightBlue)
                        .keyboardType(field.keyboardType)
                        .autocorrectionDisabled(field == .email || field == .phone)
                        .textInputAutocapitalization(field == .name ? .words : .never)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit { dismiss() }

                    if !binding.wrappedValue.isEmpty {
                        Button {
                            binding.wrappedValue = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color(hex: 0xABBDCC))
                                .font(.system(size: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(hex: 0xEEF4F9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isFocused ? Color(hex: 0x2A90D4).opacity(0.6) : Color.clear, lineWidth: 1.5)
                        )
                )
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color.white)
        .onAppear { isFocused = true }
    }
}

// MARK: - Frequent locations

private enum SavedPlaceKind: String, Identifiable {
    case home
    case workplace

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .workplace: return "Workplace"
        }
    }
}

struct FrequentLocation: Equatable {
    var address: String
    var floor: String
    var landmark: String
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var detail: String {
        [address, floor, landmark]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
}

private struct FrequentLocationEditor: View {
    let title: String
    @Binding var place: FrequentLocation

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var results: [MKMapItem] = []
    @State private var address: String
    @State private var floor: String
    @State private var landmark: String
    @State private var coordinate: CLLocationCoordinate2D
    @State private var camera: MapCameraPosition
    @State private var outsideMessage: String?
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case search, floor, landmark
    }

    init(title: String, place: Binding<FrequentLocation>) {
        self.title = title
        _place = place
        _address = State(initialValue: place.wrappedValue.address)
        _floor = State(initialValue: place.wrappedValue.floor)
        _landmark = State(initialValue: place.wrappedValue.landmark)
        let coordinate = place.wrappedValue.coordinate
        _coordinate = State(initialValue: coordinate)
        _camera = State(initialValue: .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    searchField
                    if let outsideMessage {
                        Text(outsideMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.strawberry)
                    }
                    if !results.isEmpty {
                        resultList
                    }
                    map
                    labeledField("Floor", text: $floor, field: .floor, prompt: "Floor, flat, or suite")
                    labeledField("Landmark", text: $landmark, field: .landmark, prompt: "Nearby landmark")
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.white)
            .navigationTitle("Edit \(title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(hex: 0x2A90D4))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: 0x2A90D4))
                }
            }
        }
        .task(id: query) { await search() }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color(hex: 0x49769F))
            TextField("Search Chennai", text: $query)
                .focused($focusedField, equals: .search)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.search)
            if !query.isEmpty {
                Button {
                    query = ""
                    results = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(hex: 0xABBDCC))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(fieldSurface(isFocused: focusedField == .search))
    }

    private var resultList: some View {
        VStack(spacing: 0) {
            let shown = Array(results.prefix(5))
            ForEach(Array(shown.enumerated()), id: \.offset) { index, item in
                Button {
                    choose(item)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name ?? "Place")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.midnightBlue)
                        if let subtitle = item.placemark.title, subtitle != item.name {
                            Text(subtitle)
                                .font(.system(size: 12))
                                .foregroundStyle(Color(hex: 0x49769F))
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                if index < shown.count - 1 {
                    Divider()
                }
            }
        }
    }

    private var map: some View {
        MapReader { proxy in
            Map(position: $camera) {
                Marker(title, systemImage: "mappin", coordinate: coordinate)
                    .tint(Color(hex: 0x2A90D4))
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .onTapGesture { point in
                guard let next = proxy.convert(point, from: .local) else { return }
                select(next, address: nil)
            }
        }
        .accessibilityLabel("Map of \(title). Tap to move the pin.")
    }

    private func labeledField(_ title: String, text: Binding<String>, field: Field, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(hex: 0x49769F))
            TextField(prompt, text: text)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.midnightBlue)
                .focused($focusedField, equals: field)
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(fieldSurface(isFocused: focusedField == field))
        }
    }

    private func fieldSurface(isFocused: Bool) -> some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color(hex: 0xEEF4F9))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isFocused ? Color(hex: 0x2A90D4).opacity(0.6) : Color.clear, lineWidth: 1.5)
            )
    }

    private func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            results = []
            return
        }
        try? await Task.sleep(for: .milliseconds(280))
        guard !Task.isCancelled else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        request.region = ChennaiServiceArea.shared.defaultRegion
        request.resultTypes = [.address, .pointOfInterest]

        guard let response = try? await MKLocalSearch(request: request).start() else { return }
        guard !Task.isCancelled else { return }
        results = response.mapItems.filter {
            ChennaiServiceArea.shared.contains(coordinate: $0.placemark.coordinate)
        }
        if results.isEmpty {
            outsideMessage = "No matching places inside Chennai."
        }
    }

    private func choose(_ item: MKMapItem) {
        let next = item.placemark.coordinate
        let label = item.placemark.title ?? item.name ?? address
        select(next, address: label)
        query = ""
        results = []
        focusedField = nil
    }

    private func select(_ next: CLLocationCoordinate2D, address chosen: String?) {
        guard ChennaiServiceArea.shared.contains(coordinate: next) else {
            outsideMessage = "Choose a place inside Chennai."
            return
        }
        outsideMessage = nil
        coordinate = next
        if let chosen, !chosen.isEmpty {
            address = chosen
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            camera = .region(MKCoordinateRegion(
                center: next,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))
        }
        if chosen == nil {
            Task { await reverseGeocode(next) }
        }
    }

    private func reverseGeocode(_ next: CLLocationCoordinate2D) async {
        let location = CLLocation(latitude: next.latitude, longitude: next.longitude)
        guard let placemark = try? await CLGeocoder().reverseGeocodeLocation(location).first else { return }
        let line = [placemark.name, placemark.locality]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        let unique = line.reduce(into: [String]()) { partial, part in
            if !partial.contains(part) { partial.append(part) }
        }
        if !unique.isEmpty {
            address = unique.joined(separator: ", ")
        }
    }

    private func save() {
        place = FrequentLocation(
            address: address.trimmingCharacters(in: .whitespacesAndNewlines),
            floor: floor.trimmingCharacters(in: .whitespacesAndNewlines),
            landmark: landmark.trimmingCharacters(in: .whitespacesAndNewlines),
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        dismiss()
    }
}

// MARK: - Profile Card Surface Extension
private extension View {
    func profileCard(radius: CGFloat = 24) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color.white.opacity(0.70))
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: radius, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(Color.white.opacity(0.85), lineWidth: 1.2)
                    )
                    .shadow(color: Color(hex: 0x49769F).opacity(0.12), radius: 12, x: 0, y: 4)
            )
    }
}

#Preview {
    ProfileView()
        .environment(AppRouter())
        .environment(AdImpressionTracker.shared)
}

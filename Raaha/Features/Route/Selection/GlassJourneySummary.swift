import SwiftUI

struct GlassJourneySummary: View {
    let option: RouteOption
    let origin: String
    let destination: String
    var namespace: Namespace.ID
    var ownsGeometry: Bool
    let onExpand: () -> Void
    let onConfirm: () -> Void
    var drag: AnyGesture<DragGesture.Value>? = nil

    private var transferCount: Int { max(option.chain.count - 1, 0) }

    private var transferText: String {
        transferCount == 1 ? "1 transfer" : "\(transferCount) transfers"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            info
                .contentShape(Rectangle())
                .onTapGesture(perform: onExpand)
                .optionalDrag(drag)

            Button(action: onConfirm) {
                Text("Confirm \(option.kind.title) Route")
            }
            .buttonStyle(.pillLight)
            .accessibilityHint("Navigates to the step-by-step route details")
        }
        .padding(.horizontal, 16)
        .padding(.top, 2)
        .padding(.bottom, 12)
        .modifier(RouteMatchedGeometry(active: ownsGeometry, namespace: namespace))
        .accessibilityElement(children: .contain)
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                RouteBadge(kind: option.kind)
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(option.minutes) min")
                        .font(.raahaTitle3)
                        .foregroundStyle(Color.deepSpace)
                    Text(option.fareText)
                        .font(.raahaFootnoteSemibold)
                        .foregroundStyle(Color.steelBlue)
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 7))
                    .foregroundStyle(Color.steelBlue)
                Text(origin)
                    .lineLimit(1)
                Image(systemName: "arrow.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.steelBlue)
                IconPin(size: 12)
                    .foregroundStyle(Color.transportMetro)
                Text(destination)
                    .lineLimit(1)
            }
            .font(.raahaFootnote)
            .foregroundStyle(Color.deepSpace)

            HStack(spacing: 8) {
                RouteModeChain(modes: option.chain, diameter: 26)
                Spacer(minLength: 8)
                Text(transferText)
                    .font(.raahaCaption)
                    .foregroundStyle(Color.steelBlue)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(option.kind.title), \(option.minutes) minutes, \(option.fareText), \(origin) to \(destination), \(option.chain.map(\.title).joined(separator: ", ")), \(transferText)")
        .accessibilityHint("Expands all route options")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: Text("Show all routes"), onExpand)
    }
}

struct MinimizedJourneyBar: View {
    let option: RouteOption
    let onExpand: () -> Void
    var drag: AnyGesture<DragGesture.Value>? = nil

    var body: some View {
        HStack(spacing: 8) {
            Text(option.kind.title)
                .font(.raahaFootnoteSemibold)
                .foregroundStyle(Color.deepSpace)
                .lineLimit(1)
            Text("·")
                .foregroundStyle(Color.steelBlue)
            Text("\(option.minutes) min")
                .font(.raahaFootnote)
                .foregroundStyle(Color.steelBlue)
                .lineLimit(1)
            Spacer(minLength: 8)
            Text(option.fareText)
                .font(.raahaFootnoteSemibold)
                .foregroundStyle(Color.deepSpace)
            Image(systemName: "chevron.up")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.steelBlue)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onExpand)
        .optionalDrag(drag)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(option.kind.title), \(option.minutes) minutes, \(option.fareText)")
        .accessibilityHint("Shows the journey summary")
        .accessibilityAddTraits(.isButton)
    }
}

private extension View {
    @ViewBuilder
    func optionalDrag(_ drag: AnyGesture<DragGesture.Value>?) -> some View {
        if let drag {
            self.gesture(drag)
        } else {
            self
        }
    }
}

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationSplitView {
                SidebarView(store: store.scope(state: \.navigation, action: AppFeature.Action.navigation)) { section in
                    viewStore.send(.selectSection(section))
                }
                .frame(minWidth: 320)
            } detail: {
                ZStack {
                    LinearGradient(colors: [.black, Color(red: 0.09, green: 0.11, blue: 0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    GlassBackground()
                    VStack(spacing: 0) {
                        TopBarView(store: store)
                        Divider()
                        content(for: viewStore.selectedSection)
                    }
                    .padding()
                    .toolbar { ToolbarItemGroup(placement: .keyboard) { Button("Dismiss") { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) } } }
                    .overlay(alignment: .bottomTrailing) {
                        FloatingChatButton(isPresented: viewStore.binding(get: \.
floatingChatPresented, send: AppFeature.Action.toggleChat))
                    }
                }
            }
            .navigationSplitViewStyle(.balanced)
            .onAppear { viewStore.send(.offline(.appLaunched)) }
            .sheet(isPresented: viewStore.binding(get: \.
 floatingChatPresented, send: AppFeature.Action.toggleChat)) {
                AIAssistantView(store: store.scope(state: \.aiAssistant, action: AppFeature.Action.aiAssistant))
                    .presentationDetents([.medium, .large])
            }
        }
    }

    @ViewBuilder
    private func content(for section: SidebarSection) -> some View {
        switch section {
        case .dashboard:
            DashboardView(store: store.scope(state: \.dashboard, action: AppFeature.Action.dashboard))
        case .rooms:
            RoomsView(store: store.scope(state: \.rooms, action: AppFeature.Action.rooms))
        case .reports:
            ReportsView(store: store.scope(state: \.reports, action: AppFeature.Action.reports))
        case .settings:
            SettingsView(store: store.scope(state: \.settings, action: AppFeature.Action.settings))
        case .housekeeping:
            HousekeepingView(store: store.scope(state: \.housekeeping, action: AppFeature.Action.housekeeping))
        case .search:
            SearchView(store: store.scope(state: \.search, action: AppFeature.Action.search))
        }
    }
}

struct SidebarView: View {
    let store: StoreOf<SidebarFeature>
    var onSelect: (SidebarSection) -> Void

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(selection: viewStore.binding(get: \.
 selected, send: SidebarFeature.Action.select)) {
                Section("Navigation") {
                    ForEach(viewStore.sections) { section in
                        Label(section.title, systemImage: section.icon)
                            .tag(section)
                            .onTapGesture {
                                viewStore.send(.select(section))
                                onSelect(section)
                            }
                    }
                }
            }
            .toolbar { ToolbarItem(placement: .primaryAction) { Button(action: { viewStore.send(.showSearch); onSelect(.search) }) { Label("Search", systemImage: "magnifyingglass") } } }
            .listStyle(.sidebar)
            .background(.ultraThinMaterial)
        }
    }
}

struct GlassBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 32)
            .fill(.ultraThinMaterial.opacity(0.6))
            .shadow(color: Color.cyan.opacity(0.2), radius: 16, x: 0, y: 8)
            .padding()
    }
}

struct TopBarView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Text("MotelPOS")
                    .font(.largeTitle.bold())
                Spacer()
                OfflineStatusBanner(store: store.scope(state: \.offline, action: AppFeature.Action.offline))
                Button(action: { viewStore.send(.toggleChat(true)) }) {
                    Label("Copilot", systemImage: "sparkles")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(.thinMaterial)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.cyan, lineWidth: 1.2))
                }
                .keyboardShortcut("k", modifiers: .command)
            }
            .padding(.horizontal)
        }
    }
}

struct FloatingChatButton: View {
    @Binding var isPresented: Bool
    var body: some View {
        Button(action: { isPresented.toggle() }) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 32))
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.cyan, lineWidth: 2))
                .shadow(radius: 10)
        }
        .padding()
        .keyboardShortcut("k", modifiers: [.command, .shift])
    }
}

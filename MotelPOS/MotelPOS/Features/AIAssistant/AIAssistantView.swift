import SwiftUI
import ComposableArchitecture

struct AIAssistantView: View {
    let store: StoreOf<AIAssistantFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                HStack {
                    Text("AI Copilot")
                        .font(.largeTitle.bold())
                    Spacer()
                    if viewStore.isStreaming { ProgressView().tint(.cyan) }
                }
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(viewStore.messages) { message in
                                chatBubble(message)
                                    .id(message.id)
                            }
                        }
                        .onChange(of: viewStore.messages.count) { _ in
                            if let lastID = viewStore.messages.last?.id {
                                withAnimation { proxy.scrollTo(lastID, anchor: .bottom) }
                            }
                        }
                    }
                }
                HStack {
                    TextField("Ask the assistant...", text: viewStore.binding(get: \.
input, send: AIAssistantFeature.Action.updateInput))
                        .textFieldStyle(.roundedBorder)
                        .keyboardShortcut(.return, modifiers: .command)
                    Button(action: { viewStore.send(.sendMessage) }) {
                        Image(systemName: "paperplane.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }

    private func chatBubble(_ message: AIAssistantFeature.ChatMessage) -> some View {
        HStack {
            if message.role == .assistant { Spacer(minLength: 0) }
            Text(message.content)
                .padding(12)
                .background(message.role == .assistant ? Color.cyan.opacity(0.2) : Color.blue.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            if message.role == .user { Spacer(minLength: 0) }
        }
    }
}

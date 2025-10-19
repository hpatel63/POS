import Foundation
import ComposableArchitecture

struct AIAssistantFeature: Reducer {
    struct State: Equatable, Identifiable {
        var id = UUID()
        var messages: [ChatMessage] = [ChatMessage(role: .assistant, content: "Hello! I can help with reports, occupancy, and procedures.")]
        var input: String = ""
        var isStreaming = false
        var allowedModules: Set<SettingsFeature.AIModule> = Set(SettingsFeature.AIModule.allCases)
        var isPresented: Bool = false
    }

    struct ChatMessage: Identifiable, Equatable {
        enum Role { case assistant, user }
        var id = UUID()
        var role: Role
        var content: String
        var timestamp = Date()
    }

    enum Action: Equatable {
        case updateInput(String)
        case sendMessage
        case receiveStream(Result<AIStreamEvent, Error>)
        case setPresentation(Bool)
    }

    @Dependency(\.services) var services

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .updateInput(text):
                state.input = text
                return .none
            case .sendMessage:
                guard !state.input.isEmpty else { return .none }
                let userMessage = ChatMessage(role: .user, content: state.input)
                state.messages.append(userMessage)
                let query = state.input
                let modules = state.allowedModules
                state.input = ""
                state.isStreaming = true
                // ChatGPT Request Handler
                return .run { send in
                    let contextModules = modules.map { $0.rawValue }.joined(separator: ",")
                    let request = AIRequest(query: query, context: ["modules": contextModules], role: .associate)
                    for try await event in services.ai.streamInsight(for: request).values {
                        await send(.receiveStream(.success(event)))
                    }
                }
            case let .receiveStream(.success(event)):
                state.isStreaming = !event.isFinal
                if event.isFinal {
                    state.messages.append(ChatMessage(role: .assistant, content: event.text))
                } else {
                    if var last = state.messages.last, last.role == .assistant && state.isStreaming {
                        last.content += event.text
                        state.messages[state.messages.count - 1] = last
                    } else {
                        state.messages.append(ChatMessage(role: .assistant, content: event.text))
                    }
                }
                return .none
            case .receiveStream(.failure):
                state.isStreaming = false
                state.messages.append(ChatMessage(role: .assistant, content: "I’m sorry, I couldn’t process that."))
                return .none
            case let .setPresentation(presented):
                state.isPresented = presented
                return .none
            }
        }
    }
}

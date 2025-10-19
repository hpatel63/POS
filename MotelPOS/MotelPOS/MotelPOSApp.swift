import SwiftUI
import ComposableArchitecture

@main
struct MotelPOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let store: StoreOf<AppFeature>

    init() {
        let persistenceController = PersistenceController.shared
        let services = ServiceContainer.live(persistence: persistenceController)
        self.store = Store(initialState: AppFeature.State(), reducer: {
            AppFeature()
        }, withDependencies: {
            $0.persistenceController = persistenceController
            $0.services = services
            $0.uuid = .incrementing
            $0.date = .now
        })
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .preferredColorScheme(.dark)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.isIdleTimerDisabled = true
        return true
    }
}

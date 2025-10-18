import SwiftUI
import PencilKit
import ComposableArchitecture

struct CheckInView: View {
    let store: StoreOf<CheckInFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 20) {
                progress(step: viewStore.step)
                content(for: viewStore.step, viewStore: viewStore)
                HStack {
                    if viewStore.step != .guestInfo {
                        Button("Back") { viewStore.send(.previousStep) }
                            .buttonStyle(.bordered)
                    }
                    Spacer()
                    if viewStore.step != .confirmation {
                        Button(viewStore.step == .payment ? "Capture" : "Next") {
                            if viewStore.step == .payment {
                                viewStore.send(.capturePayment)
                            } else {
                                viewStore.send(.nextStep)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewStore.isProcessing)
                    } else {
                        Button("Finish") { viewStore.send(.finish) }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.cyan.opacity(0.5), lineWidth: 1.5))
        }
    }

    private func progress(step: CheckInFeature.Step) -> some View {
        HStack(spacing: 12) {
            ForEach(CheckInFeature.Step.allCases, id: \.self) { stage in
                Circle()
                    .fill(stage.rawValue <= step.rawValue ? Color.cyan : Color.gray.opacity(0.3))
                    .frame(width: 14, height: 14)
                    .overlay(Text(String(stage.rawValue + 1)).font(.caption2))
            }
        }
    }

    @ViewBuilder
    private func content(for step: CheckInFeature.Step, viewStore: ViewStoreOf<CheckInFeature>) -> some View {
        switch step {
        case .guestInfo:
            GuestInfoForm(guest: viewStore.binding(get: \.
guest, send: CheckInFeature.Action.updateGuest))
        case .idScan:
            VStack(spacing: 12) {
                Text("Scan ID")
                    .font(.title3)
                Button("Simulate Scan") {
                    viewStore.send(.scanID(Data()))
                }
                if viewStore.isProcessing {
                    ProgressView().tint(.cyan)
                }
            }
        case .stay:
            StayInfoForm(stay: viewStore.binding(get: \.
stay, send: CheckInFeature.Action.updateStay), room: viewStore.room)
        case .payment:
            PaymentInfoForm(payment: viewStore.binding(get: \.
payment, send: CheckInFeature.Action.updatePayment))
        case .signature:
            SignatureCaptureView(onComplete: { data in viewStore.send(.completeSignature(data)) })
        case .confirmation:
            VStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.cyan)
                Text(viewStore.confirmationMessage ?? "Check-in complete")
                    .font(.title2)
            }
        }
    }
}

struct GuestInfoForm: View {
    @Binding var guest: CheckInFeature.GuestInfo
    var body: some View {
        Form {
            Section("Guest") {
                TextField("First Name", text: $guest.firstName)
                TextField("Last Name", text: $guest.lastName)
                TextField("Email", text: $guest.email)
                TextField("Phone", text: $guest.phone)
            }
            Section("Identification") {
                TextField("ID Number", text: $guest.idNumber)
                TextField("State", text: $guest.idState)
            }
        }
    }
}

struct StayInfoForm: View {
    @Binding var stay: CheckInFeature.StayInfo
    var room: Room
    var body: some View {
        Form {
            Section("Room") {
                Text("Room \(room.number)")
                Stepper("Adults: \(stay.adults)", value: $stay.adults, in: 1...4)
                Stepper("Children: \(stay.children)", value: $stay.children, in: 0...4)
                Stepper("Pets: \(stay.pets)", value: $stay.pets, in: 0...2)
            }
            Section("Rates") {
                TextField("Nightly Rate", value: $stay.nightlyRate, format: .currency(code: "USD"))
                TextField("Tax Rate", value: $stay.taxRate, format: .percent)
            }
        }
    }
}

struct PaymentInfoForm: View {
    @Binding var payment: CheckInFeature.PaymentInfo
    var body: some View {
        Form {
            Section("Method") {
                Picker("Method", selection: $payment.method) {
                    ForEach(Payment.Method.allCases, id: \.self) { method in
                        Text(method.rawValue.capitalized).tag(method)
                    }
                }
            }
            Section("Details") {
                Text("Amount: $\(payment.amount as NSDecimalNumber)")
                if payment.method == .cashApp {
                    Text("Scan QR for \(payment.cashAppHandle)")
                }
            }
        }
    }
}

struct SignatureCaptureView: View {
    var onComplete: (Data) -> Void
    @State private var drawing = PKDrawing()

    var body: some View {
        VStack(spacing: 12) {
            Text("Signature")
                .font(.title3)
            Canvas { context, size in
                let image = drawing.image(from: CGRect(origin: .zero, size: size), scale: UIScreen.main.scale)
                context.draw(Image(uiImage: image), in: CGRect(origin: .zero, size: size))
            }
            .background(Color.black.opacity(0.2))
            .frame(height: 200)
            Button("Save Signature") {
                onComplete(Data(drawing.dataRepresentation()))
            }
        }
    }
}

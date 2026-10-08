import SwiftUI
import SharedKit

@L1 @L2
struct AdminRootView: View {
    @ObservedObject var session: AdminSessionViewModel

    var body: some View {
        Group {
            switch session.screen {
            case .loading: ProgressView()
            case .setup: OwnerSetupView(session: session)
            case .signIn: AdminSignInView(session: session)
            case .changePassword: ChangePasswordView(session: session)
            case .main: ContentView(session: session)
            }
        }
        .task { await session.load() }
    }
}

@L1
private struct OwnerSetupView: View {
    @ObservedObject var session: AdminSessionViewModel
    @State private var name = ""
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        AccessForm(title: "Tulajdonos létrehozása",
                   subtitle: "Még nincs adminisztrátor. Hozd létre az első, tulajdonosi fiókot.",
                   message: session.errorMessage, session: session) {
            TextField("Név", text: $name)
            TextField("Felhasználónév", text: $username)
            SecureField("Jelszó (legalább 8 karakter)", text: $password)
            Button("Létrehozás") { Task { await session.setUpOwner(name: name, username: username, password: password) } }
                .keyboardShortcut(.defaultAction)
                .disabled(name.isEmpty || username.isEmpty || password.isEmpty)
        }
    }
}

@L1
private struct AdminSignInView: View {
    @ObservedObject var session: AdminSessionViewModel
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        AccessForm(title: "Bejelentkezés", subtitle: "Nightlife Manager", message: session.errorMessage, session: session) {
            LabeledContent {
                HStack {
                    TextField("Felhasználónév", text: $username)
                    if !session.snapshot.companyDomain.isEmpty {
                        Text("@" + session.snapshot.companyDomain).foregroundStyle(.secondary)
                    }
                }
            } label: {
                Text("Felhasználónév")
            }
            SecureField("Jelszó", text: $password)
            Button("Bejelentkezés") { Task { await session.signIn(username: username, password: password) } }
                .keyboardShortcut(.defaultAction)
                .disabled(username.isEmpty || password.isEmpty)
        }
    }
}

@L1
private struct ChangePasswordView: View {
    @ObservedObject var session: AdminSessionViewModel
    @State private var password = ""
    @State private var repeated = ""

    var body: some View {
        AccessForm(title: "Új jelszó",
                   subtitle: "Ideiglenes jelszóval jelentkeztél be, válassz új jelszót.",
                   message: session.errorMessage ?? (repeated.isEmpty || password == repeated ? nil : "A két jelszó nem egyezik"),
                   session: nil) {
            SecureField("Új jelszó", text: $password)
            SecureField("Új jelszó újra", text: $repeated)
            Button("Mentés") { Task { await session.chooseNewPassword(password) } }
                .keyboardShortcut(.defaultAction)
                .disabled(password.isEmpty || password != repeated)
            Button("Mégse") { Task { await session.signOut() } }
        }
    }
}

@L1
private struct AccessForm<Fields: View>: View {
    let title: String
    let subtitle: String
    let message: String?
    var session: AdminSessionViewModel?
    @ViewBuilder let fields: Fields
    @State private var editingService = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2.crop.circle").font(.system(size: 56)).foregroundStyle(.purple)
            Text(title).font(.title.bold())
            Text(subtitle).foregroundStyle(.secondary)
            Form { fields }
                .formStyle(.grouped)
                .frame(width: 420)
            if let message {
                Label(message, systemImage: "exclamationmark.triangle").foregroundStyle(.red)
            }
            if let session {
                HStack {
                    Text("Hitelesítés: " + (session.serviceURL?.absoluteString ?? "helyi fiókok ezen a Macen"))
                        .foregroundStyle(.secondary)
                    Button("Módosítás") { editingService = true }.buttonStyle(.link)
                }
                .font(.footnote)
                .sheet(isPresented: $editingService) { ServiceSheet(session: session) }
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@L1
private struct ServiceSheet: View {
    @ObservedObject var session: AdminSessionViewModel
    @State private var address = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            TextField("Szolgáltatás címe (pl. https://auth.clubneon.hu)", text: $address)
            Text("Üresen hagyva a fiókok helyben, ezen a Macen tárolódnak.").foregroundStyle(.secondary)
        }
        .padding()
        .frame(minWidth: 420)
        .navigationTitle("Hitelesítési szolgáltatás")
        .onAppear { address = session.serviceURL?.absoluteString ?? "" }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Mégse") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Mentés") {
                    let url = URL(string: address.trimmingCharacters(in: .whitespaces)).flatMap { $0.scheme == nil ? nil : $0 }
                    UserDefaults.standard.set(url?.absoluteString, forKey: AdminSessionViewModel.serviceURLKey)
                    Task { await session.useService(at: url) }
                    dismiss()
                }
            }
        }
    }
}

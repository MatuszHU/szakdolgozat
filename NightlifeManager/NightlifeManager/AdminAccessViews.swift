import SwiftUI
import SharedKit

@L1 @L2
struct AdminRootView: View {
    @ObservedObject var session: AdminSessionViewModel

    var body: some View {
        switch session.screen {
        case .setup: OwnerSetupView(session: session)
        case .signIn: AdminSignInView(session: session)
        case .changePassword: ChangePasswordView(session: session)
        case .main: ContentView(session: session)
        }
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
                   message: session.errorMessage) {
            TextField("Név", text: $name)
            TextField("Felhasználónév", text: $username)
            SecureField("Jelszó (legalább 8 karakter)", text: $password)
            Button("Létrehozás") { session.setUpOwner(name: name, username: username, password: password) }
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
        AccessForm(title: "Bejelentkezés", subtitle: "Nightlife Manager", message: session.errorMessage) {
            LabeledContent {
                HStack {
                    TextField("Felhasználónév", text: $username)
                    if !session.directory.companyDomain.isEmpty {
                        Text("@" + session.directory.companyDomain).foregroundStyle(.secondary)
                    }
                }
            } label: {
                Text("Felhasználónév")
            }
            SecureField("Jelszó", text: $password)
            Button("Bejelentkezés") { session.signIn(username: username, password: password) }
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
                   message: session.errorMessage ?? (repeated.isEmpty || password == repeated ? nil : "A két jelszó nem egyezik")) {
            SecureField("Új jelszó", text: $password)
            SecureField("Új jelszó újra", text: $repeated)
            Button("Mentés") { session.chooseNewPassword(password) }
                .keyboardShortcut(.defaultAction)
                .disabled(password.isEmpty || password != repeated)
            Button("Mégse") { session.signOut() }
        }
    }
}

@L1
private struct AccessForm<Fields: View>: View {
    let title: String
    let subtitle: String
    let message: String?
    @ViewBuilder let fields: Fields

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
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

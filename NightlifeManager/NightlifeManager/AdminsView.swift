import SwiftUI
import SharedKit

@L3 @L1
struct AdminsView: View {
    @ObservedObject var session: AdminSessionViewModel
    @State private var showingNewAdmin = false
    @State private var resetTarget: AdminUser?

    private var canManage: Bool { session.currentAdmin?.role.canManageAdmins == true }

    var body: some View {
        VStack(alignment: .leading) {
            List(session.directory.admins) { admin in
                HStack {
                    VStack(alignment: .leading) {
                        Text(admin.name).font(.headline)
                        Text(session.email(of: admin)).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(Self.title(of: admin.role)).foregroundStyle(.secondary)
                    if canManage && admin.signInMethod == .password && admin.id != session.currentAdmin?.id {
                        Button("Jelszó visszaállítása", systemImage: "key") { resetTarget = admin }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.borderless)
                    }
                    if canManage {
                        Button("Törlés", systemImage: "trash", role: .destructive) { session.removeAdmin(id: admin.id) }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.borderless)
                    }
                }
            }
            if let message = session.errorMessage {
                Label(message, systemImage: "exclamationmark.triangle").foregroundStyle(.red).padding()
            }
        }
        .navigationTitle("Adminisztrátorok")
        .toolbar {
            Button("Új adminisztrátor", systemImage: "person.badge.plus") { showingNewAdmin = true }
                .disabled(!canManage)
        }
        .sheet(isPresented: $showingNewAdmin) {
            NewAdminSheet(canCreateOwner: session.currentAdmin?.role == .owner) { name, username, role, password in
                session.addAdmin(name: name, username: username, role: role, temporaryPassword: password)
            }
        }
        .sheet(item: $resetTarget) { admin in
            ResetPasswordSheet(name: admin.name) { password in
                session.resetPassword(of: admin.id, to: password)
            }
        }
    }

    static func title(of role: AdminRole) -> String {
        switch role {
        case .owner: return "Tulajdonos"
        case .userAdmin: return "Felhasználó-adminisztrátor"
        case .businessManager: return "Üzletvezető"
        }
    }
}

@L3
private struct NewAdminSheet: View {
    let canCreateOwner: Bool
    let onSave: (String, String, AdminRole, String?) -> Void
    @State private var name = ""
    @State private var username = ""
    @State private var role = AdminRole.businessManager
    @State private var usesPassword = true
    @State private var temporaryPassword = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            TextField("Név", text: $name)
            TextField("Felhasználónév", text: $username)
            Picker("Jogosultság", selection: $role) {
                Text(AdminsView.title(of: .businessManager)).tag(AdminRole.businessManager)
                Text(AdminsView.title(of: .userAdmin)).tag(AdminRole.userAdmin)
                if canCreateOwner { Text(AdminsView.title(of: .owner)).tag(AdminRole.owner) }
            }
            Picker("Bejelentkezés", selection: $usesPassword) {
                Text("Jelszóval").tag(true)
                Text("Sign in with Apple").tag(false)
            }
            if usesPassword {
                SecureField("Ideiglenes jelszó", text: $temporaryPassword)
            }
        }
        .padding()
        .frame(minWidth: 380)
        .navigationTitle("Új adminisztrátor")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Mégse") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Hozzáadás") {
                    onSave(name, username, role, usesPassword ? temporaryPassword : nil)
                    dismiss()
                }
                .disabled(name.isEmpty || username.isEmpty || (usesPassword && temporaryPassword.isEmpty))
            }
        }
    }
}

@L1
private struct ResetPasswordSheet: View {
    let name: String
    let onSave: (String) -> Void
    @State private var password = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Text("\(name) a következő bejelentkezéskor új jelszót választ.")
            SecureField("Ideiglenes jelszó", text: $password)
        }
        .padding()
        .frame(minWidth: 360)
        .navigationTitle("Jelszó visszaállítása")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Mégse") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Mentés") { onSave(password); dismiss() }.disabled(password.isEmpty)
            }
        }
    }
}

@L6 @L1
struct AdminSettingsView: View {
    @ObservedObject var session: AdminSessionViewModel
    @State private var domain = ""
    @State private var currentPassword = ""
    @State private var newPassword = ""

    var body: some View {
        Form {
            Section("Munkavállalói funkciók") {
                ForEach(WorkerFeature.allCases, id: \.self) { feature in
                    Toggle(Self.title(of: feature), isOn: Binding(
                        get: { session.directory.enabledWorkerFeatures.contains(feature) },
                        set: { session.setWorkerFeature(feature, enabled: $0) }))
                }
            }
            if session.currentAdmin?.signInMethod == .password {
                Section("Saját jelszó") {
                    SecureField("Jelenlegi jelszó", text: $currentPassword)
                    SecureField("Új jelszó", text: $newPassword)
                    Button("Jelszó módosítása") {
                        session.changeOwnPassword(current: currentPassword, new: newPassword)
                        if session.errorMessage == nil {
                            currentPassword = ""
                            newPassword = ""
                        }
                    }
                    .disabled(currentPassword.isEmpty || newPassword.isEmpty)
                }
            }
            Section("Vállalati domain") {
                TextField("pl. clubneon.hu", text: $domain)
                    .disabled(session.currentAdmin?.role != .owner)
                Button("Mentés") { session.setCompanyDomain(domain) }
                    .disabled(session.currentAdmin?.role != .owner || domain.isEmpty)
                if session.currentAdmin?.role != .owner {
                    Text("A domaint csak tulajdonos módosíthatja.").foregroundStyle(.secondary)
                }
            }
            if let message = session.errorMessage {
                Label(message, systemImage: "exclamationmark.triangle").foregroundStyle(.red)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Beállítások")
        .onAppear { domain = session.directory.companyDomain }
    }

    static func title(of feature: WorkerFeature) -> String {
        switch feature {
        case .profilePicture: return "Profilkép"
        case .statistics: return "Összesítés"
        case .guide: return "Útmutató"
        case .supplyRequests: return "Készletkérés"
        }
    }
}

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var presenceManager: PresenceManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            content
            Divider()
            quitButton
        }
        .frame(width: 260)
    }

    private var header: some View {
        Text("Presence")
            .font(.headline)
            .padding(.leading, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var content: some View {
        if !presenceManager.isConnected {
            Text("Connecting…")
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
        } else if presenceManager.people.isEmpty {
            Text("No data received")
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
        } else {
            ForEach(presenceManager.people) { person in
                PersonRow(person: person)
                if person.id != presenceManager.people.last?.id {
                    Divider()
                        .padding(.leading, 44)
                }
            }
        }
    }

    private var quitButton: some View {
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PersonRow: View {
    let person: Person

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: person.connected ? "person.fill" : "person")
                .font(.system(size: 24))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .fontWeight(person.connected ? .semibold : .regular)
                Text(person.statusText)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

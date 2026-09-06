import SwiftUI

struct FactionChatLiveView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openURL) private var openURL
    let session: AuthSession

    @State private var channel = "general"
    @State private var messages: [CommunityChatMessage] = []
    @State private var draft = ""
    @State private var loading = true
    @State private var sending = false
    @State private var error: String?
    @State private var reportTarget: CommunityChatMessage?
    @State private var reportReason = ""
    @State private var blocked: Set<Int> = []

    private var channels: [String] {
        var result = ["general", "war", "oc"]
        if session.isLiteralLeader { result.append("leadership") }
        return result
    }

    private var visibleMessages: [CommunityChatMessage] {
        messages.filter { !blocked.contains($0.authorID) }
    }

    var body: some View {
        CommandDetailScaffold(title: "Faction Chat", eyebrow: "TORNFCA • COMMUNITY", subtitle: "\(session.factionName) • live TornFCA community chat for your current faction", accent: TornTheme.blue) {
            Picker("Channel", selection: $channel) {
                ForEach(channels, id: \.self) { Text($0.capitalized).tag($0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: channel) { _, _ in Task { await refresh(showLoading: true) } }

            if loading {
                LoadingCommandCard(text: "Opening your faction community…", accent: TornTheme.blue)
            } else if let error, messages.isEmpty {
                ErrorCommandCard(message: error) { Task { await refresh(showLoading: true) } }
            } else {
                CommandPanel(title: channel.capitalized, subtitle: "Tap another member's message for profile, report and block options") {
                    if visibleMessages.isEmpty {
                        Text("No visible messages in this channel yet.")
                            .font(.system(size: 12)).foregroundStyle(TornTheme.muted)
                    }
                    ForEach(visibleMessages) { message in
                        ChatMessageBubble(message: message, mine: message.authorID == session.playerID)
                            .contextMenu {
                                if message.authorID > 0 && message.authorID != session.playerID {
                                    Button("View Torn Profile") {
                                        if let url = URL(string: "https://www.torn.com/profiles.php?XID=\(message.authorID)") { openURL(url) }
                                    }
                                    Button("Report Message") { reportTarget = message }
                                    Button("Block User", role: .destructive) { block(message.authorID) }
                                }
                            }
                    }
                }

                CommandPanel(title: "Message", subtitle: "Send to \(channel). Messages are limited to 1,000 characters.") {
                    TextEditor(text: $draft)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(TornTheme.text)
                        .frame(minHeight: 82)
                        .padding(8)
                        .background(TornTheme.background2, in: RoundedRectangle(cornerRadius: 11))
                        .overlay(RoundedRectangle(cornerRadius: 11).stroke(TornTheme.line))
                    Button { Task { await send() } } label: {
                        HStack {
                            if sending { ProgressView().tint(.white) }
                            Text(sending ? "Sending…" : "Send Message")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 46)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(TornTheme.blue)
                    .disabled(sending || draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if !blocked.isEmpty {
                    Button("Unblock All (\(blocked.count))") { unblockAll() }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(TornTheme.gold2)
                }
            }
        }
        .task(id: channel) {
            loadBlocked()
            await refresh(showLoading: true)
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                if Task.isCancelled { break }
                await refresh(showLoading: false)
            }
        }
        .alert("Report Message", isPresented: Binding(get: { reportTarget != nil }, set: { if !$0 { reportTarget = nil } })) {
            TextField("Reason", text: $reportReason)
            Button("Cancel", role: .cancel) { reportTarget = nil; reportReason = "" }
            Button("Report", role: .destructive) { Task { await report() } }
        } message: {
            Text("Reports are sent to your faction's TornFCA moderation queue.")
        }
    }

    private func refresh(showLoading: Bool) async {
        if showLoading { loading = true }
        guard let key = appState.storedAPIKey(), !key.isEmpty else { error = "Reconnect your Torn API key first."; loading = false; return }
        do {
            let snapshot = try await TornCommunityClient.shared.chatSnapshot(apiKey: key, channel: channel)
            if snapshot.factionID > 0 && snapshot.factionID != session.factionID {
                error = "Torn now reports a different faction. Sign out and reconnect so the whole app can refresh faction scope safely."
            } else {
                messages = snapshot.messages
                error = nil
            }
        } catch {
            self.error = error.localizedDescription
        }
        loading = false
    }

    private func send() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        guard text.count <= 1000 else { error = "Messages are limited to 1,000 characters."; return }
        guard let key = appState.storedAPIKey() else { return }
        sending = true
        do {
            try await TornCommunityClient.shared.sendChatMessage(apiKey: key, channel: channel, message: text, expectedFactionID: session.factionID)
            draft = ""
            await refresh(showLoading: false)
        } catch { self.error = error.localizedDescription }
        sending = false
    }

    private func report() async {
        guard let target = reportTarget, let key = appState.storedAPIKey() else { return }
        let reason = reportReason.trimmingCharacters(in: .whitespacesAndNewlines)
        do { try await TornCommunityClient.shared.reportChatMessage(apiKey: key, messageID: target.id, reason: reason.isEmpty ? "Reported from TornFCA iOS" : reason) }
        catch { self.error = error.localizedDescription }
        reportTarget = nil; reportReason = ""
    }

    private func block(_ playerID: Int) {
        blocked.insert(playerID)
        persistBlocked()
    }

    private func unblockAll() {
        blocked.removeAll()
        persistBlocked()
    }

    private func blockedKey() -> String { "tornfca.chat.blocked.f\(session.factionID)" }
    private func loadBlocked() {
        let values = UserDefaults.standard.array(forKey: blockedKey()) as? [Int] ?? []
        blocked = Set(values)
    }
    private func persistBlocked() { UserDefaults.standard.set(Array(blocked), forKey: blockedKey()) }
}

private struct ChatMessageBubble: View {
    let message: CommunityChatMessage
    let mine: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(mine ? "YOU • \(message.channel.uppercased())" : message.channel.uppercased())
                    .font(.system(size: 8.5, weight: .bold)).tracking(0.7)
                    .foregroundStyle(mine ? TornTheme.green : TornTheme.blue)
                Spacer()
                if message.createdAt > 0 {
                    Text(Date(timeIntervalSince1970: TimeInterval(message.createdAt)).formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 9)).foregroundStyle(TornTheme.muted)
                }
            }
            Text(message.authorName).font(.system(size: 12.5, weight: .bold)).foregroundStyle(TornTheme.text)
            Text(message.message).font(.system(size: 12)).foregroundStyle(TornTheme.muted).textSelection(.enabled)
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(mine ? TornTheme.green.opacity(0.07) : TornTheme.panel3.opacity(0.45), in: RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(mine ? TornTheme.green.opacity(0.4) : TornTheme.lineSoft))
    }
}

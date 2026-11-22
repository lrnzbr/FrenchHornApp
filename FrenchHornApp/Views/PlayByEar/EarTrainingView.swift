import AdagioCore
import SwiftUI

/// Ear-training home: progress at a glance and three ways to start a session.
/// Tap answers only for now; play-it-back needs the microphone wiring that is still to come.
struct EarTrainingView: View {
    let instrument: Instrument
    var isActive = true

    @StateObject private var store = EarTrainingStore()
    @State private var route: EarRoute?

    private var profile: InstrumentProfile? {
        instrument.profile
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AdagioTheme.Space.lg) {
                summary
                Button {
                    route = EarRoute(focus: .daily)
                } label: {
                    Label("Daily practice", systemImage: "sparkles")
                }
                .buttonStyle(AdagioPrimaryButtonStyle())
                .accessibilityIdentifier("ear.start.daily")

                HStack(spacing: AdagioTheme.Space.md) {
                    Button("Notes") { route = EarRoute(focus: .notes) }
                        .buttonStyle(AdagioSecondaryButtonStyle())
                        .accessibilityIdentifier("ear.start.notes")
                    Button("Intervals") { route = EarRoute(focus: .intervals) }
                        .buttonStyle(AdagioSecondaryButtonStyle())
                        .accessibilityIdentifier("ear.start.intervals")
                }

                Text("Eight short questions. Listen first, then choose what you heard. Notes are named as your \(instrument.name) reads them.")
                    .font(AdagioTheme.TypeStyle.support)
                    .foregroundColor(AdagioTheme.Colors.secondaryInk)
            }
            .padding(AdagioTheme.Space.xl)
        }
        .fullScreenCover(item: $route) { route in
            EarSessionView(focus: route.focus, profile: profile, store: store)
        }
        .onChange(of: isActive) { active in
            if !active { route = nil }
        }
    }

    private var summary: some View {
        let progress = store.progress
        return VStack(alignment: .leading, spacing: AdagioTheme.Space.sm) {
            Text("Level \(progress.level)")
                .font(AdagioTheme.TypeStyle.sectionTitle)
            ProgressView(value: progress.levelProgress)
                .accessibilityLabel("Progress to the next level")
            HStack(spacing: AdagioTheme.Space.lg) {
                stat("Today", "\(min(progress.dailyAttempts, EarProgress.dailyGoal)) of \(EarProgress.dailyGoal)")
                stat("Streak", progress.dayStreak == 1 ? "1 day" : "\(progress.dayStreak) days")
                stat("First-try", "\(Int((progress.accuracy * 100).rounded()))%")
            }
        }
        .padding(AdagioTheme.Space.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .adagioSurface()
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: AdagioTheme.Space.xs) {
            Text(label)
                .font(AdagioTheme.TypeStyle.label)
                .foregroundColor(AdagioTheme.Colors.secondaryInk)
            Text(value)
                .font(AdagioTheme.TypeStyle.body)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct EarRoute: Identifiable {
    let id = UUID()
    let focus: EarFocus
}

/// One session of questions, driven by `AdagioCore.EarSession`.
struct EarSessionView: View {
    @ObservedObject var store: EarTrainingStore
    let profile: InstrumentProfile?

    @StateObject private var player = EarPromptPlayer()
    @State private var session: EarSession
    @State private var hasHeardPrompt = false
    @Environment(\.dismiss) private var dismiss

    init(focus: EarFocus, profile: InstrumentProfile?, store: EarTrainingStore) {
        self.store = store
        self.profile = profile
        var generator = SystemRandomNumberGenerator()
        let progress = store.progress
        _session = State(initialValue: EarSession(
            focus: focus,
            difficulty: progress.recommendedDifficulty(for: focus),
            inputMode: .tap,
            profile: profile,
            mastery: progress.mastery,
            echoAllowed: false,
            now: Date(),
            using: &generator))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AdagioTheme.Space.lg) {
                    if session.isFinished {
                        finished
                    } else {
                        question
                    }
                }
                .padding(AdagioTheme.Space.xl)
            }
            .background(AdagioTheme.Colors.canvas.ignoresSafeArea())
            .navigationTitle(session.isFinished ? "Session complete" : "Question \(session.questionIndex + 1) of \(session.length)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { close() }
                        .accessibilityIdentifier("ear.close")
                }
            }
        }
        .navigationViewStyle(.stack)
        .foregroundColor(AdagioTheme.Colors.ink)
        .tint(AdagioTheme.Colors.accent)
        .stopPlaybackOnAudioChange { player.stop() }
    }

    // MARK: - Question

    @ViewBuilder private var question: some View {
        let challenge = session.challenge

        Text(challenge.question)
            .font(AdagioTheme.TypeStyle.sectionTitle)
            .accessibilityAddTraits(.isHeader)
        Text(challenge.contextText)
            .font(AdagioTheme.TypeStyle.support)
            .foregroundColor(AdagioTheme.Colors.secondaryInk)

        Button {
            hasHeardPrompt = true
            player.play(midiNotes: challenge.playbackMIDI)
        } label: {
            Label(player.isPlaying ? "Playing…" : (hasHeardPrompt ? "Replay prompt" : "Play prompt"),
                  systemImage: player.isPlaying ? "speaker.wave.3.fill" : "play.fill")
        }
        .buttonStyle(AdagioPrimaryButtonStyle())
        .disabled(player.isPlaying)
        .accessibilityIdentifier("ear.prompt")

        if let message = player.errorMessage {
            Text(message)
                .font(.callout)
                .foregroundColor(AdagioTheme.Colors.attention)
        }

        VStack(spacing: AdagioTheme.Space.sm) {
            ForEach(challenge.answers) { answer in
                answerButton(answer, challenge: challenge)
            }
        }

        if case .feedback(let feedback) = session.phase {
            feedbackCard(feedback, challenge: challenge)
        }
    }

    private func answerButton(_ answer: EarAnswer, challenge: EarChallenge) -> some View {
        let answered = session.phase != .awaitingAnswer
        let isCorrect = answer.id == challenge.correctAnswerID
        return Button {
            player.stop()
            session.submitTap(answerID: answer.id, progress: &store.progress, now: Date())
        } label: {
            HStack {
                Text(answer.primary)
                    .font(.headline)
                    .frame(minWidth: 44, alignment: .leading)
                Text(answer.secondary)
                    .font(AdagioTheme.TypeStyle.support)
                Spacer()
                if answered && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AdagioTheme.Colors.success)
                        .accessibilityLabel("Correct answer")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(AdagioSecondaryButtonStyle())
        .disabled(answered || !hasHeardPrompt)
        .accessibilityIdentifier("ear.answer.\(answer.id)")
    }

    private func feedbackCard(_ feedback: EarSession.Feedback, challenge: EarChallenge) -> some View {
        let headline: String
        let isRight: Bool
        switch feedback {
        case .correct(let xp):
            headline = "Correct · +\(xp) XP"
            isRight = true
        case .incorrect:
            headline = "Not quite"
            isRight = false
        case .revealed:
            headline = "Here is the answer"
            isRight = false
        }
        let isLast = session.questionIndex + 1 >= session.length

        return VStack(alignment: .leading, spacing: AdagioTheme.Space.sm) {
            Text(headline)
                .font(.headline)
                .foregroundColor(isRight ? AdagioTheme.Colors.success : AdagioTheme.Colors.attention)
            Text(challenge.feedbackTitle)
                .font(AdagioTheme.TypeStyle.sectionTitle)
            Text(challenge.feedbackDetail)
                .font(AdagioTheme.TypeStyle.support)
            Button(isLast ? "Finish" : "Next") { next() }
                .buttonStyle(AdagioPrimaryButtonStyle())
                .accessibilityIdentifier("ear.next")
        }
        .padding(AdagioTheme.Space.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .adagioSurface()
    }

    // MARK: - Summary

    private var finished: some View {
        VStack(alignment: .leading, spacing: AdagioTheme.Space.lg) {
            Text("\(session.correctCount) of \(session.length) correct")
                .font(AdagioTheme.TypeStyle.screenTitle)
            Text("+\(session.xpEarned) XP · Level \(store.progress.level)")
                .font(AdagioTheme.TypeStyle.body)
                .foregroundColor(AdagioTheme.Colors.secondaryInk)
            Button("Done") { close() }
                .buttonStyle(AdagioPrimaryButtonStyle())
                .accessibilityIdentifier("ear.done")
        }
    }

    // MARK: - Actions

    private func next() {
        player.stop()
        var generator = SystemRandomNumberGenerator()
        session.advance(mastery: store.progress.mastery, now: Date(), using: &generator)
        hasHeardPrompt = false
    }

    private func close() {
        player.stop()
        dismiss()
    }
}

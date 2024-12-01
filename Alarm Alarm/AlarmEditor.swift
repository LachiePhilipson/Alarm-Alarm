//
//  CreateEditAlarmView.swift
//  Alarm Alarm
//
//  Created by Lachlan Philipson on 14/12/2024.
//

import SwiftUI

struct CreateEditAlarmView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var alarm: Alarm
    let onSave: (Alarm) -> Void

    init(alarm: Alarm, onSave: @escaping (Alarm) -> Void) {
        _alarm = State(initialValue: alarm)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack {
                    DatePicker(
                        "Time",
                        selection: $alarm.time,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.bottom, -30)
                }
                List {
                    LabeledContent("Label") {
                        TextField(
                            "Label", text: $alarm.label, prompt: Text("Alarm")
                        )
                        .multilineTextAlignment(.trailing)
                    }

                    NavigationLink {
                        Form {
                            Section {
                                Toggle("Slowly increase volume", isOn: $alarm.slowlyIncreaseVolume)
                            }
                            Picker("Sound", selection: $alarm.sound) {
                                ForEach(Alarm.availableSounds, id: \.self) {
                                    sound in
                                    Text(sound).tag(sound)
                                }
                            }
                            .pickerStyle(.inline)
                            .labelsHidden()
                            .onChange(of: alarm.sound) { _, newSound in
                                SoundManager.shared.playSound(
                                    soundName: newSound)
                            }
                        }
                        .navigationTitle("Sound")
                        .navigationBarTitleDisplayMode(.inline)
                        .onDisappear {
                            SoundManager.shared.stopSoundWithFadeOut()
                        }
                    } label: {
                        HStack {
                            Text("Sound")
                            Spacer()
                            Text(alarm.sound)
                                .foregroundColor(.secondary)
                        }
                    }

                    Section {
                        Toggle("Snooze", isOn: $alarm.snooze)
                        if alarm.snooze {
                            Stepper(
                                "\(alarm.snoozeTime) Minute Snooze",
                                value: $alarm.snoozeTime,
                                in: 1...30)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(alarm.label.isEmpty ? "Add Alarm" : "Edit Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(alarm)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateEditAlarmView(
            alarm: Alarm(
                id: UUID(),
                label: "Morning Alarm",
                time: Calendar.current.date(
                    from: DateComponents(
                        calendar: Calendar.current,
                        hour: 7,
                        minute: 0)
                ) ?? Date(),
                enabled: true,
                snooze: true,
                snoozeTime: 5,
                sound: "Piano",
                slowlyIncreaseVolume: true
            )
        ) { updatedAlarm in
            print("Saved alarm: \(updatedAlarm)")
        }
    }
}

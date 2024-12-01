//
//  AlarmRow.swift
//  Alarm Alarm
//
//  Created by Lachlan Philipson on 13/12/2024.
//

import SwiftUI

struct AlarmRow: View {
    @Binding var alarm: Alarm
    @EnvironmentObject private var AlarmManager: AlarmManager
    @Environment(\.editMode) private var editMode

    private var timeString: String {
        let time = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
        return String(format: "%d:%02d", time.hour ?? 12, time.minute ?? 0)
    }

    private var periodString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter.string(from: alarm.time)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Text(timeString)
                        .font(.system(size: 56, weight: .light))
                    Text(periodString)
                        .font(.title)
                        .textCase(.uppercase)
                        .padding(.leading, -7)
                }
                Text(alarm.label)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Toggle(
                "Enable alarm",
                isOn: Binding(
                    get: { alarm.enabled },
                    set: { newValue in
                        alarm.enabled = newValue
                        let updatedAlarm = alarm
                        AlarmManager.updateAlarm(updatedAlarm)
                    }
                )
            )
            .opacity(editMode?.wrappedValue.isEditing == false ? 1 : 0)
            .animation(.default, value: editMode?.wrappedValue.isEditing)
            .labelsHidden()
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
                .font(.caption)
                .opacity(editMode?.wrappedValue.isEditing == true ? 1 : 0)
                .animation(.default, value: editMode?.wrappedValue.isEditing)
        }
    }
}

#Preview {
    List {
        // Morning alarm - enabled
        Button {} label: {
            AlarmRow(
                alarm: .constant(Alarm(
                    id: UUID(),
                    label: "Wake Up",
                    time: Calendar.current.date(from: DateComponents(hour: 7, minute: 30)) ?? Date(),
                    enabled: true,
                    snooze: true,
                    snoozeTime: 5,
                    sound: "Piano",
                    slowlyIncreaseVolume: true
                ))
            )
        }
        .buttonStyle(.plain)
        
        // Afternoon alarm - disabled
        Button {} label: {
            AlarmRow(
                alarm: .constant(Alarm(
                    id: UUID(),
                    label: "Afternoon Break",
                    time: Calendar.current.date(from: DateComponents(hour: 14, minute: 15)) ?? Date(),
                    enabled: false,
                    snooze: false,
                    snoozeTime: 5,
                    sound: "Piano",
                    slowlyIncreaseVolume: true
                ))
            )
        }
        .buttonStyle(.plain)
        
        // Evening alarm - enabled with longer label
        Button {} label: {
            AlarmRow(
                alarm: .constant(Alarm(
                    id: UUID(),
                    label: "Evening Meditation Time",
                    time: Calendar.current.date(from: DateComponents(hour: 20, minute: 59)) ?? Date(),
                    enabled: true,
                    snooze: true,
                    snoozeTime: 10,
                    sound: "Piano",
                    slowlyIncreaseVolume: true
                ))
            )
        }
        .buttonStyle(.plain)
    }
    .environmentObject(AlarmManager.shared)
}

//
//  AlarmListView.swift
//  Alarm Alarm
//
//  Created by Lachlan Philipson on 13/12/2024.
//

import SwiftUI

struct AlarmListView: View {
    @EnvironmentObject private var AlarmManager: AlarmManager
    @State private var editingAlarm: Alarm?
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            ZStack {
                if AlarmManager.alarms.isEmpty {
                    ContentUnavailableView(
                        "No Alarms",
                        systemImage: "alarm",
                        description: Text("Tap + to create an alarm")
                    )
                    .foregroundStyle(.secondary)
                } else {
                    List($AlarmManager.alarms, editActions: .delete) { $alarm in
                        Button {
                            editingAlarm = alarm
                        } label: {
                            AlarmRow(alarm: $alarm)
                                .contentShape(Rectangle())  // Makes entire row tappable
                        }
                        .buttonStyle(.plain)
                        .swipeActions(
                            edge: .trailing, allowsFullSwipe: true
                        ) {
                            Button(role: .destructive) {
                                AlarmManager.removeAlarm(alarm)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !AlarmManager.alarms.isEmpty {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingAlarm = Alarm(
                            id: UUID(),
                            label: "Alarm",
                            time: Date(),
                            enabled: true,
                            snooze: true,
                            snoozeTime: 5,
                            sound: "Piano",
                            slowlyIncreaseVolume: true
                        )
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("Add Alarm")
                    }
                }
            }
            .sheet(item: $editingAlarm) { alarm in
                NavigationStack {
                    CreateEditAlarmView(alarm: alarm) { updatedAlarm in
                        if AlarmManager.alarms.firstIndex(where: { $0.id == alarm.id }) != nil {
                            AlarmManager.updateAlarm(updatedAlarm)
                        } else {
                            AlarmManager.addAlarm(updatedAlarm)
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .onChange(of: editingAlarm) { oldValue, newValue in
                withAnimation {
                    if newValue != nil {
                        editMode = .inactive
                    }
                }
            }
        }
    }
}

#Preview {
    AlarmListView()
        .environmentObject(AlarmManager.shared)
}

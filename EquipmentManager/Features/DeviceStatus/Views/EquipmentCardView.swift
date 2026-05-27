//
//  EquipmentCardView.swift
//  EquipmentManager
//
//  Created by Marek Hac on 25/05/2026.
//
import Combine
import SwiftUI

struct EquipmentCardView: View {

    let equipment: Equipment
    let updateStatusPublisher: PassthroughSubject<StatusUpdateEvent, Never>

    @State private var isShowingStatusDialog = false

    var body: some View {
        HStack(spacing: 16) {
            statusView
            equipmentInfoView
            Spacer(minLength: 12)
            optionsButton
        }
        .padding(16)
        .background(cardBackground)
        .confirmationDialog(
            "Change Equipment Status",
            isPresented: $isShowingStatusDialog,
            titleVisibility: .visible
        ) {

            statusButton(
                title: "Set STOPPED",
                status: .stopped
            )

            statusButton(
                title: "Set STARTUP",
                status: .startup
            )

            statusButton(
                title: "Set PRODUCING",
                status: .producing
            )

            Button("Cancel", role: .cancel) { }
        }
    }
}

// MARK: - Subviews

private extension EquipmentCardView {
    var statusView: some View {
        ZStack {
            Circle()
                .fill(statusColor.opacity(0.15))
                .frame(width: 60, height: 60)
            Circle()
                .stroke(statusColor, lineWidth: 2)
                .frame(width: 50, height: 50)
            Image(systemName: equipment.status.icon)
                .font(.title3)
                .foregroundStyle(statusColor)
        }
    }

    var equipmentInfoView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(equipment.name)
                .font(.headline)
            Text(equipment.status.rawValue)
                .font(.subheadline)
                .foregroundStyle(statusColor)
            Text(
                equipment.lastUpdated.formatted(
                    date: .omitted,
                    time: .standard
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    var optionsButton: some View {
        Button {
            isShowingStatusDialog = true
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 60, height: 60)
        }
        .buttonStyle(.plain)
    }

    var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(statusColor.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        statusColor.opacity(0.25),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Helpers

private extension EquipmentCardView {
    var statusColor: Color {
        equipment.status.color
    }

    @ViewBuilder
    func statusButton(title: String, status: EquipmentStatus) -> some View {
        Button(title) {
            updateStatusPublisher.send(
                StatusUpdateEvent(equipmentId: equipment.id, status: status)
            )
        }
    }
}


//
//  DeviceStatusView.swift
//  EquipmentManager
//
//  Created by Marek Hac on 25/05/2026.
//

import SwiftUI

struct DeviceStatusView: View {
    @StateObject var viewModel: DeviceStatusViewModel

    // MARK: - Body
    
    var body: some View {
        VStack {
            title
            content
        }
        .task {
            viewModel.start()
            await viewModel.loadEquipment()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

private extension DeviceStatusView {
    @ViewBuilder
    var content: some View {
        if viewModel.isLoading {
            loadingView
        } else {
            VStack() {
                status
                Spacer()
                equipmentListView
            }
        }
    }
    
    private var title: some View {
        Text("Equipment Manager")
            .font(.title)
    }
    
    private var status: some View {
        Text("Status: \(viewModel.isConnected ? "Online" : "Offline")")
            .font(.subheadline)
            .foregroundColor(viewModel.isConnected ? .green : .red)
    }

    var loadingView: some View {
        ProgressView("Loading equipment...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension DeviceStatusView {
    var equipmentListView: some View {
        List {
            ForEach(viewModel.equipments) { equipment in
                EquipmentCardView(
                    equipment: equipment,
                    updateStatusPublisher: viewModel.updateStatusPublisher
                )
                .listRowSeparator(.hidden)
                .listRowInsets(
                    EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                )
            }
        }
        .listStyle(.plain)
    }
}

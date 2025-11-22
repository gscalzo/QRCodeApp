//
//  ContentView.swift
//  QRCodeApp
//
//  Created by giordano scalzo on 22/11/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QRCodeViewModel()

    var body: some View {
        NavigationSplitView {
            HistorySidebarView(viewModel: viewModel)
        } detail: {
            QRCodeGeneratorView(viewModel: viewModel)
        }
        .navigationSplitViewStyle(.balanced)
        .alert(isPresented: errorBinding) {
            Alert(
                title: Text("Something went wrong"),
                message: Text(viewModel.errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK")) { viewModel.dismissError() }
            )
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { newValue in
                if newValue == false {
                    viewModel.dismissError()
                }
            }
        )
    }
}

#Preview {
    ContentView()
}

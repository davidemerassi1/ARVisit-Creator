//
//  ContentView.swift
//  MuseoAccessibile Creator
//
//  Created by Davide Merassi on 15/06/25.
//

import SwiftUI
import RealityKit
import ARKit

struct RoomView : View {
    @State private var selectedPOI: Poi? = nil
    @State private var editablePOI: Poi? = nil
    @StateObject private var viewModel: RoomViewModel
    @State var showingAlert = false
    
    init(roomURL: URL) {
        _viewModel = StateObject(wrappedValue: RoomViewModel(roomURL: roomURL))
    }
    
    var body: some View {
        ZStack {
            ARViewContainer(selectedPOI: $selectedPOI, viewModel: viewModel)
                .ignoresSafeArea(edges: .bottom)
        }
        .sheet(item: $selectedPOI) { poi in
            PoiDetailView(
                poi: Binding(
                    get: { editablePOI ?? poi },
                    set: { editablePOI = $0 }
                ),
                onSave: {
                    if let poiToSave = editablePOI {
                        if viewModel.addPoi(poi: poiToSave) {
                            selectedPOI = nil
                            editablePOI = nil
                        } else {
                            showingAlert = true
                        }
                    }
                    
                },
                onDelete: {
                    if let poiToDelete = editablePOI {
                        viewModel.removePoi(poi: poiToDelete)
                    }
                    selectedPOI = nil
                    editablePOI = nil
                },
                viewModel: viewModel
            )
            .onAppear {
                editablePOI = poi // inizializza con una copia
            }
            .interactiveDismissDisabled()
            .alert("Compilare tutti i campi obbligatori", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        .navigationTitle(viewModel.roomName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

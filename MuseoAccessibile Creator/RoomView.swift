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
    
    init(roomURL: URL) {
        _viewModel = StateObject(wrappedValue: RoomViewModel(roomURL: roomURL))
    }
    
    var body: some View {
        let arViewContainer = ARViewContainer(selectedPOI: $selectedPOI, viewModel: viewModel)
        ZStack {
            arViewContainer.edgesIgnoringSafeArea(.all)
        }
        .sheet(item: $selectedPOI) { poi in
            PoiDetailView(
                poi: Binding(
                    get: { editablePOI ?? poi },
                    set: { editablePOI = $0 }
                ),
                onSave: {
                    if let poiToSave = editablePOI {
                        viewModel.addPoi(poi: poiToSave)
                    }
                    selectedPOI = nil
                    editablePOI = nil
                },
                onDelete: {
                    if let poiToDelete = editablePOI {
                        viewModel.removePoi(poi: poiToDelete)
                    }
                    selectedPOI = nil
                    editablePOI = nil
                }
            )
            .onAppear {
                editablePOI = poi // inizializza con una copia
            }.interactiveDismissDisabled()
        }
    }
}

//
//  ContentView.swift
//  ARVisit Creator
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
            
            if viewModel.selectedAnchor != nil {
                VStack {
                    Spacer()
                    HStack (spacing: 16) {
                        Button(action: {
                                viewModel.moveSelectedAnchor(offset: SIMD3<Float>(0, 0.02, 0))
                            }) {
                                Image(systemName: "arrow.up")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }

                            Button(action: {
                                viewModel.moveSelectedAnchor(offset: SIMD3<Float>(0, -0.02, 0))
                            }) {
                                Image(systemName: "arrow.down")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }

                            Button(action: {
                                viewModel.moveSelectedAnchor(offset: SIMD3<Float>(-0.02, 0, 0))
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }

                            Button(action: {
                                viewModel.moveSelectedAnchor(offset: SIMD3<Float>(0.02, 0, 0))
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }

                            Button(action: {
                                viewModel.moveSelectedAnchor(offset: SIMD3<Float>(0, 0, -0.02))
                            }) {
                                Image(systemName: "arrow.up.right")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }

                            Button(action: {
                                viewModel.moveSelectedAnchor(offset: SIMD3<Float>(0, 0, 0.02))
                            }) {
                                Image(systemName: "arrow.down.left")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        Button("Fine") {
                            viewModel.unselect()
                        }.font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
            }
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
        .alert(
            "È necessario concedere il permesso alla fotocamera",
            isPresented: $viewModel.showCameraAlert
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Passa a Impostazioni per abilitarlo.")
        }
    }
}

//
//  DetailView.swift
//  MuseoAccessibile Creator
//
//  Created by Davide Merassi on 15/06/25.
//

import SwiftUI

struct PoiDetailView: View {
    @Binding var poi: Poi
    @State var showingConfirmation: Bool = false
    @State var showingAudioImporter: Bool = false
    var onSave: () -> Void
    var onDelete: () -> Void
    let viewModel: RoomViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informazioni")) {
                    TextField("Nome", text: $poi.name)
                    
                    TextField("Descrizione", text: $poi.description, axis: .vertical)
                    
                    Picker("Tipo", selection: $poi.type) {
                        ForEach(Poi.PoiType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                Section(header: Text("Audioguida")) {
                    if let audioUrl = $poi.wrappedValue.audioguideUrl {
                        Text(audioUrl.lastPathComponent)
                    }
                    Button($poi.wrappedValue.audioguideUrl == nil ? "Carica Audio" : "Cambia") {
                        showingAudioImporter = true
                    }
                }
            }
            .navigationTitle("Opzioni punto")
            //.navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Elimina", role: .destructive) {
                        showingConfirmation = true
                    }.foregroundStyle(Color(.red))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        onSave()
                    }
                }
            }
            .confirmationDialog(
                "Eliminare punto?",
                isPresented: $showingConfirmation
            ) {
                Button("Elimina", role: .destructive) {
                    onDelete()
                }
                Button("Annulla", role: .cancel) { }
            } message: {
                Text("Questa azione è irreversibile.")
            }
            .fileImporter(
                isPresented: $showingAudioImporter,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: false
            ) { result in
                do {
                    guard let selectedFile: URL = try result.get().first else { return }
                    guard selectedFile.startAccessingSecurityScopedResource() else {
                        print("Accesso negato al file audio")
                        return
                    }
                    defer { selectedFile.stopAccessingSecurityScopedResource() }
                    
                    $poi.wrappedValue.audioguideUrl = viewModel.importFile(url: selectedFile)
                } catch {
                    print("Errore selezione file audio: \(error)")
                }
            }
        }
    }
}

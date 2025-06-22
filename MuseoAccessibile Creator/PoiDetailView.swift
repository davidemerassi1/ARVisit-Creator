//
//  DetailView.swift
//  MuseoAccessibile Creator
//
//  Created by Davide Merassi on 15/06/25.
//

import SwiftUI
import PhotosUI

struct PoiDetailView: View {
    @Binding var poi: Poi
    @State var showingConfirmation: Bool = false
    @State var showingAudioImporter: Bool = false
    @State var selectedImage: PhotosPickerItem?
    @State var img: UIImage?
    var onSave: () -> Void
    var onDelete: () -> Void
    let viewModel: RoomViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section() {
                    TextField("Nome", text: $poi.name)
                    
                    Picker("Tipo", selection: $poi.type) {
                        ForEach(Poi.PoiType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                if (poi.type == Poi.PoiType.interest) {
                    Section(header: Text("Audioguida")) {
                        if let audioUrl = $poi.wrappedValue.audioguideUrl {
                            Text(audioUrl.lastPathComponent)
                        }
                        Button($poi.wrappedValue.audioguideUrl == nil ? "Carica Audio" : "Cambia") {
                            showingAudioImporter = true
                        }
                    }
                    Section(header: Text("Immagine")) {
                        if let img {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                        }
                        
                        PhotosPicker(img == nil ? "Scegli immagine" : "Cambia immagine", selection: $selectedImage, matching: .images)
                            .task(id: selectedImage) {
                                guard let newItem = selectedImage else { return }
                                
                                do {
                                    if let data = try await newItem.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        img = uiImage
                                        $poi.wrappedValue.imageUrl = viewModel.saveImage(image: uiImage)
                                    }
                                } catch {
                                    print("Errore caricamento immagine: \(error)")
                                }
                            }
                        
                        if img != nil {
                            Button("Elimina immagine") {
                                img = nil
                                selectedImage = nil
                                $poi.wrappedValue.imageUrl = nil
                            }
                        }
                    }
                    Section() {
                        Toggle("Notifica quando vicino", isOn: $poi.notify)
                        if (poi.notify) {
                            HStack {
                                TextField("Distanza a cui notificare", value: $poi.distance, formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                                Text("metri")
                            }
                        }
                    }
                    Section(header: Text("Altre info")) {
                        TextField("Descrizione", text: $poi.description, axis: .vertical)
                        TextField("Link", text: $poi.linkToDescription)
                    }
                } else if (poi.type == Poi.PoiType.service) {
                    Picker("Servizio", selection: $poi.serviceType) {
                        ForEach(Poi.ServiceType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } else {
                    Section {
                        TextField("Descrizione", text: $poi.description, axis: .vertical)
                    }
                    Section {
                        HStack {
                            TextField("Distanza a cui notificare", value: $poi.distance, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                            Text("metri")
                        }
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
                    
                    $poi.wrappedValue.audioguideUrl = viewModel.saveFile(url: selectedFile)
                } catch {
                    print("Errore selezione file audio: \(error)")
                }
            }
            .task {
                if let url = poi.imageUrl, img==nil {
                    self.img = viewModel.getImage(url: url)
                }
            }
        }
    }
}

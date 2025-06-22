//
//  RoomSelectorView.swift
//  MuseoAccessibile Creator
//
//  Created by Davide Merassi on 18/06/25.
//

import SwiftUI

struct RoomSelectorView : View {
    @State var rooms = StorageManager.getRoomUrls()
    @State private var showingAlert = false
    @State private var newRoomName = ""
    @State private var editMode: EditMode = .inactive
    
    var body : some View {
        NavigationStack {
            List {
                ForEach(rooms, id: \.self) { roomURL in
                    NavigationLink(String(roomURL.lastPathComponent.dropFirst(5))) {
                        RoomView(roomURL: roomURL)
                    }
                }
                .onDelete { indexSet in     //indexset contiene gli indici da eliminare dopo aver premuto fine
                    for index in indexSet {
                        let roomURL = rooms[index]
                        if StorageManager.removeRoomDirectory(roomURL: roomURL) {
                            rooms.remove(at: index)
                        }
                    }
                    if rooms.isEmpty {
                        editMode = .inactive
                    }
                }
            }
            .overlay {
                    if rooms.isEmpty {
                        Text("Nessun ambiente presente.\nTocca \"+\" per crearne uno")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                    }
                }
            .navigationTitle("Ambienti")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAlert = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .alert("Nome ambiente", isPresented: $showingAlert) {
                TextField("", text: $newRoomName).autocorrectionDisabled(true)
                Button("OK") {
                    if let newDir = StorageManager.newRoomDirectory(name: newRoomName) {
                        rooms.append(newDir)
                    }
                    newRoomName = ""
                }
                Button("Annulla", role: .cancel) { }
            }
        }
    }
}

#Preview {
    
}

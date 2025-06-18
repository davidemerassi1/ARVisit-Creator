//
//  DetailView.swift
//  MuseoAccessibile Creator
//
//  Created by Davide Merassi on 15/06/25.
//

import SwiftUI

struct PoiDetailView: View {
    @Binding var poi: Poi
    var onSave: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informazioni")) {
                    TextField("Nome", text: $poi.name)
                    
                    TextField("Descrizione", text: $poi.description, axis: .vertical)
                }
            }
            .navigationTitle("Opzioni punto")
            //.navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Elimina", role: .destructive) {
                        onDelete()
                    }.foregroundStyle(Color(.red))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        onSave()
                    }
                }
            }
        }
    }
}

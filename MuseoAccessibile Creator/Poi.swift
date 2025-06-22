//
//  Poi.swift
//  MuseoAccessibile Creator
//
//  Created by Davide Merassi on 15/06/25.
//

import Foundation
import RealityFoundation

struct Poi: Identifiable, Codable, Equatable {
    enum PoiType: String, Codable, CaseIterable, Identifiable {
        case interest = "Punto di interesse",
             service = "Punto di servizio",
             danger = "Punto pericoloso"
        var id: String { self.rawValue }
    }
    
    var id: UUID
    var name: String = ""
    var description: String = ""
    var type: PoiType = .interest
    var audioguideUrl: URL?
    var imageUrl: URL?
    
    init(id: UUID = UUID()) {
        self.id = id
    }
}

//
//  Poi.swift
//  MuseoAccessibile Creator
//
//  Created by Davide Merassi on 15/06/25.
//

import Foundation
import RealityFoundation

struct Poi: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String = ""
    var description: String = ""
    
    init(id: UUID = UUID()) {
        self.id = id
    }
}

//
//  RoomModel.swift
//  MuseoAccessibile Creator
//
//  Created by Davide Merassi on 18/06/25.
//

import ARKit
import RealityKit

class RoomViewModel: ObservableObject {
    private var storageManager: StorageManager
    var arAnchors: [String: ARAnchor] = [:]
    var pois: [String: Poi] = [:]
    var arView: ARView = ARView(frame: .zero)
    
    init(roomURL: URL) {
        storageManager = StorageManager(roomURL: roomURL)
        pois = storageManager.loadPois()
    }
    
    func getWorldMap() -> ARWorldMap? {
        storageManager.loadWorldMap()
    }
    
    func addPoi(poi: Poi) {
        pois[poi.id.uuidString] = poi
        storageManager.save(pois: Array(pois.values), session: arView.session)
    }
    
    func removePoi(poi: Poi) {
        removeAnchor(for: poi)
        storageManager.save(pois: Array(pois.values), session: arView.session)
    }
    
    func addAnchor(for poi: Poi, position: simd_float4x4) {
        let arAnchor = ARAnchor(name: poi.id.uuidString, transform: position)
        arView.session.add(anchor: arAnchor)
        let anchorEntity = AnchorEntity(anchor: arAnchor)
        anchorEntity.name = arAnchor.name ?? "Unknown"
        let sphere = ModelEntity(mesh: .generateSphere(radius: 0.03))
        sphere.model?.materials = [SimpleMaterial(color: .blue, isMetallic: false)]
        sphere.generateCollisionShapes(recursive: true)
        anchorEntity.addChild(sphere)
        arView.scene.anchors.append(anchorEntity)
        arAnchors[arAnchor.name!] = arAnchor
    }
    
    func removeAnchor(for poi: Poi) {
        pois.removeValue(forKey: poi.id.uuidString)
        let anchor = arAnchors[poi.id.uuidString]
        if let anchor {
            arView.session.remove(anchor: anchor)
            arAnchors.removeValue(forKey: poi.id.uuidString)
        }
    }
}

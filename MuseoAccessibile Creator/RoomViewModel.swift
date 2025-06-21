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
    var roomName: String
    
    init(roomURL: URL) {
        storageManager = StorageManager(roomURL: roomURL)
        pois = storageManager.loadPois()
        roomName = String(roomURL.lastPathComponent.dropFirst(5))
    }
    
    func getWorldMap() -> ARWorldMap? {
        storageManager.loadWorldMap()
    }
    
    func addPoi(poi: Poi) {
        pois[poi.id.uuidString] = poi
        setColor(poi: poi)
        storageManager.save(pois: Array(pois.values), session: arView.session)
    }
    
    func removePoi(poi: Poi) {
        removeAnchor(for: poi)
        pois.removeValue(forKey: poi.id.uuidString)
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
        let anchor = arAnchors[poi.id.uuidString]
        if let anchor {
            arView.session.remove(anchor: anchor)
            arAnchors.removeValue(forKey: poi.id.uuidString)
        }
    }
    
    func setColor(poi: Poi) {
        if let anchorEntity = arView.scene.anchors.first(where: { $0.name == poi.id.uuidString }) as? AnchorEntity {
            if let model = anchorEntity.children.first as? ModelEntity {
                switch poi.type {
                case .interest:
                    model.model?.materials = [SimpleMaterial(color: .blue, isMetallic: false)]
                case .service:
                    model.model?.materials = [SimpleMaterial(color: .green, isMetallic: false)]
                case .danger:
                    model.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
                }
            }
        }
    }
    
    func importFile(url: URL) -> URL? {
        do {
            return try storageManager.saveFile(from: url)
        } catch {
            print("Errore:")
            print(error)
            return nil
        }
    }
}

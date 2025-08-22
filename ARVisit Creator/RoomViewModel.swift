//
//  RoomModel.swift
//  ARVisit Creator
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
    @Published var selectedAnchor: ARAnchor?
    @Published var showCameraAlert = false
    
    init(roomURL: URL) {
        storageManager = StorageManager(roomURL: roomURL)
        pois = storageManager.loadPois()
        roomName = String(roomURL.lastPathComponent.dropFirst(5))
    }
    
    func getWorldMap() -> ARWorldMap? {
        storageManager.loadWorldMap()
    }
    
    func addPoi(poi: Poi) -> Bool {
        var poi = poi
        if (!checkPoi(poi: &poi)) {
            return false
        }
        
        pois[poi.id.uuidString] = poi
        setColor(poi: poi)
        storageManager.save(pois: Array(pois.values), session: arView.session)
        return true
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
    
    func saveFile(url: URL) -> URL? {
        do {
            return try storageManager.saveFile(from: url)
        } catch {
            print("Errore: \(error)")
            return nil
        }
    }
    
    func saveImage(image: UIImage) -> URL? {
        do {
            return try storageManager.saveImage(image: image)
        } catch {
            print("Errore: \(error)")
            return nil
        }
    }
    
    func getImage(url: URL) -> UIImage? {
        do {
            let data = try Data(contentsOf: url)
            print(data)
            return UIImage(data: data)
        } catch {
            print(error)
        }
        return nil
    }
    
    func checkPoi(poi: inout Poi) -> Bool {
        switch poi.type {
        case .interest:
            guard (!poi.notify || poi.distance != nil) && !poi.name.isEmpty && (poi.audioguideUrl != nil || poi.imageUrl != nil || !poi.description.isEmpty || !poi.linkToDescription.isEmpty) else {
                return false
            }
            if !poi.notify {
                poi.distance = nil
            }
            poi.serviceType = nil
        case .service:
            guard poi.serviceType != nil else {
                return false
            }
            poi.audioguideUrl = nil
            poi.imageUrl = nil
            poi.description = ""
            poi.distance = nil
            poi.notify = false
            poi.linkToDescription = ""
        case .danger:
            guard poi.distance != nil && !poi.name.isEmpty && !poi.description.isEmpty else {
                return false
            }
            poi.audioguideUrl = nil
            poi.imageUrl = nil
            poi.notify = false
            poi.serviceType = nil
            poi.linkToDescription = ""
        }
        return true
    }
    
    func select(anchorId: String) {
        selectedAnchor = arAnchors[anchorId]
    }
    
    func unselect() {
        selectedAnchor = nil
        storageManager.saveWorldMap(from: arView.session)
    }
    
    func moveSelectedAnchor(offset: SIMD3<Float>) {
        guard let anchor = selectedAnchor else { return }
        
        let currentPosition = anchor.transform.translation
        
        // Crea la nuova trasformazione con la stessa orientazione
        var newTransform = anchor.transform
        newTransform.translation += offset
        
        arView.session.remove(anchor: anchor)
        let newAnchor = ARAnchor(name: anchor.name!, transform: newTransform)
        arView.session.add(anchor: newAnchor)
        arAnchors[anchor.name!] = newAnchor
        selectedAnchor = newAnchor
    }
}

extension simd_float4x4 {
    var translation: SIMD3<Float> {
        get {
            return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
        }
        set {
            columns.3 = SIMD4<Float>(newValue.x, newValue.y, newValue.z, columns.3.w)
        }
        
    }
}

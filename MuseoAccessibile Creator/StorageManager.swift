//
//  ArMapManager.swift
//  MuseoAccessibile Creator
//
//  Created by Davide Merassi on 15/06/25.
//

import RealityKit
import ARKit
import SwiftUICore

struct StorageManager {
    //var pois: [String: Poi] = [:]
    //var worldMap: ARWorldMap?
    
    var roomURL: URL
    
    func loadWorldMap() -> ARWorldMap? {
        let url = roomURL.appendingPathComponent("worldMap")
        do {
            let data = try Data(contentsOf: url)
            guard let map = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else {
                print("WorldMap non valida")
                return nil
            }
            return map
        } catch {
            print("Errore nel caricamento della mappa: \(error)")
            return nil
        }
    }
    
    func saveWorldMap(from session: ARSession) {
        session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap else {
                print("Errore nel recuperare ARWorldMap: \(error?.localizedDescription ?? "Sconosciuto")")
                return
            }
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                let url = roomURL.appendingPathComponent("worldMap")
                try data.write(to: url)
                print("WorldMap salvata con successo. Sono stati salvati \(worldMap?.anchors.count ?? 0) ancore)")
            } catch {
                print("Errore nel salvataggio: \(error)")
            }
        }
    }
    
    func loadPois() -> [String : Poi] {
        let decoder = JSONDecoder()
        let url = roomURL.appendingPathComponent("pois.json")
        do {
            let data = try Data(contentsOf: url)
            let pois = try decoder.decode([Poi].self, from: data)
            let poiDict = Dictionary(uniqueKeysWithValues: pois.map { ($0.id.uuidString, $0) })
            print("Caricati \(poiDict.count) POI")
            print(poiDict)
            return poiDict
        } catch {
            print("Errore nel caricamento dei POI: \(error)")
            return [:]
        }
    }
    
    func savePois(pois: [Poi]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(pois)
            let url = roomURL.appendingPathComponent("pois.json")
            try data.write(to: url)
            print("POI salvati correttamente in \(url)")
            //print("Salvati \(pois)")
        } catch {
            print("Errore nel salvataggio dei POI: \(error)")
        }
    }
    
    func save(pois: [Poi], session: ARSession) {
        savePois(pois: pois)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.saveWorldMap(from: session)
        }
    }
    
    /*
     func add(poi: Poi, session: ARSession) {
     pois[poi.id.uuidString] = poi
     saveWorldMap(from: session)
     savePois(pois: Array(pois.values))
     }
     
     func remove(poi: Poi, session: ARSession) {
     pois.removeValue(forKey: poi.id.uuidString)
     savePois(pois: Array(pois.values))
     DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
     self.saveWorldMap(from: session)
     }
     }
     
     */
    
    private static func getSharedContainerURL() -> URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.MuseoAccessibile")
    }
    
    static func getRoomUrls() -> [URL] {
        do {
            if let groupURL = getSharedContainerURL() {
                let contents = try FileManager.default.contentsOfDirectory(at: groupURL, includingPropertiesForKeys: nil, options: [])
                
                let folders = contents.filter { url in
                    var isDirectory: ObjCBool = false
                    FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
                    return isDirectory.boolValue && url.lastPathComponent.starts(with: "Room-")
                }
                
                print("Sottocartelle trovate:")
                folders.forEach { print($0.lastPathComponent) }
                return folders
            } else {
                print("Errore nel trovare la directory condivisa")
            }
            
        } catch {
            print("Errore nel leggere la directory: \(error)")
        }
        return []
    }
    
    static func newRoomDirectory(name: String) -> URL? {
        if let groupURL = getSharedContainerURL() {
            let newDirURL = groupURL.appendingPathComponent("Room-" + name, isDirectory: true)
            do {
                try FileManager.default.createDirectory(at: newDirURL, withIntermediateDirectories: true, attributes: nil)
                print("Cartella creata: \(newDirURL)")
                return newDirURL
            } catch {
                print("Errore nella creazione della cartella: \(error.localizedDescription)")
            }
        } else {
            print("Errore nel trovare la directory condivisa")
        }
        return nil
    }
    
    static func removeRoomDirectory(roomURL: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: roomURL)
            return true
        } catch {
            print("Errore nel rimuovere la directory: \(error)")
            return false
        }
    }
    
    func saveFile(from sourceURL: URL) throws -> URL {
        let destinationURL = roomURL.appendingPathComponent(sourceURL.lastPathComponent)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }
}

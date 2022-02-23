//
//  ARObject.swift
//  RealityKitSample
//  
//  Created by ji-no on R 4/02/23
//  
//

import RealityKit
import UIKit

// https://developer.apple.com/jp/augmented-reality/quick-look/
enum ModelType: String {
    case AirForce
    case ChairSwan
    case Teapot
    case ToyBiplane
    
    static var all: [ModelType] = [
        .AirForce,
        .ChairSwan,
        .Teapot,
        .ToyBiplane
    ]
}

class ModelComponent: RealityKit.Component, Equatable {
    enum State {
        case idle
        case selected
        case canceling
    }
    var state: State = .idle
    weak var entity: ModelEntity?
    weak var box: ModelEntity?
    
    init(entity: ModelEntity) {
        self.entity = entity
    }
    
    var name: String? {
        return entity?.name
    }
    
    func isSelected() -> Bool {
        return state == .selected
    }
    
    func select() {
        state = .selected

        if let entity = self.entity {
            let size = entity.visualBounds(relativeTo: entity).extents
            let boxMesh = MeshResource.generateBox(size: size)
            let boxMaterial = SimpleMaterial(color: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5), roughness: 0, isMetallic: true)
            let boxEntity = ModelEntity(mesh: boxMesh, materials: [boxMaterial])
            boxEntity.position.y = size.y / 2
            entity.addChild(boxEntity)

            self.box = boxEntity
        }
    }
    
    func cancel() {
        state = .idle
        box?.removeFromParent()
        box = nil
    }
    
    func removeObject() {
        guard let entity = self.entity else { return }
        
        let duration = 0.2

        entity.transform.scale = SIMD3(repeating: 1.0)
        var scaleTransform = entity.transform
        scaleTransform.scale = SIMD3(repeating: 0.01)
        entity.move(to: scaleTransform, relativeTo: entity.parent, duration: duration, timingFunction: .linear)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            entity.removeFromParent()
        }
    }

    func spawnAnimation() {
        guard let entity = self.entity else { return }

        entity.transform.scale = SIMD3(repeating: 0.0)
        var scaleTransform = entity.transform
        scaleTransform.scale = SIMD3(repeating: 1.0)
        entity.move(to: scaleTransform, relativeTo: entity.parent, duration: 0.2, timingFunction: .linear)
    }
    
    
    static func == (lhs: ModelComponent, rhs: ModelComponent) -> Bool {
        return lhs.entity == rhs.entity
    }
    
}

extension Entity {
    
    static func createARModel(type: ModelType, position: SIMD3<Float>) -> ModelEntity? {
        if let entity = try? Entity.loadModel(named: type.rawValue) {
            var scale: Float = 1.0
            switch type {
            case .AirForce:
                scale = 0.01
            case .ChairSwan:
                scale = 0.003
            case .Teapot:
                scale = 0.01
            case .ToyBiplane:
                scale = 0.01
            }
            entity.setScale(SIMD3(repeating: scale), relativeTo: nil)
            let modelEntity = ModelEntity()
            modelEntity.addChild(entity)
            modelEntity.name = type.rawValue
            modelEntity.position = position
            modelEntity.generateCollisionShapes(recursive: true)
            modelEntity.components[ModelComponent.self] = ModelComponent(entity: modelEntity)
            return modelEntity
        }
        return nil
    }
    
    func getModelComponent() -> ModelComponent? {
        if let modelComponent = components[ModelComponent.self] as? ModelComponent {
            return modelComponent
        }
        return parent?.components[ModelComponent.self]
    }
    
    func isModelEntity() -> Bool {
        return getModelComponent() != nil
    }

}

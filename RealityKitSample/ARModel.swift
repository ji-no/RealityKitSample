//
//  ARObject.swift
//  RealityKitSample
//  
//  Created by ji-no on R 4/02/23
//  
//

import RealityKit

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
    }
    
    func cancel() {
        state = .idle
    }
    
    func removeObject() {
        entity?.removeFromParent()
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

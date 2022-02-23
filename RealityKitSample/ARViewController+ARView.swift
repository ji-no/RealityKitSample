//
//  ARViewController+ARSCNView.swift
//  ARSample
//  
//  Created by ji-no on R 4/02/05
//  
//

import ARKit
import RealityKit

extension ARViewController {

    func setUpScene() {
        configureWorldTracking()
        setupPhysicsOrigin()
        setupCameraTracker()
        setUpGesture()
        ModelComponent.registerComponent()
    }

    private func setupPhysicsOrigin() {
        let physicsOrigin = Entity()
        physicsOrigin.scale = .init(repeating: 0.1)
        let anchor = AnchorEntity(world: SIMD3<Float>())
        anchor.addChild(physicsOrigin)
        arView.scene.addAnchor(anchor)
        arView.physicsOrigin = physicsOrigin
    }

    private func setupCameraTracker() {
        let camera = AnchorEntity(world: SIMD3<Float>())
        self.camera = camera
        arView.scene.addAnchor(camera)
    }

    private func configureWorldTracking() {
        let configuration = ARWorldTrackingConfiguration()

        let sceneReconstruction: ARWorldTrackingConfiguration.SceneReconstruction = .mesh
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(sceneReconstruction) {
            configuration.sceneReconstruction = sceneReconstruction
        }

        let frameSemantics: ARConfiguration.FrameSemantics = [.smoothedSceneDepth, .sceneDepth]
        if ARWorldTrackingConfiguration.supportsFrameSemantics(frameSemantics) {
            configuration.frameSemantics.insert(frameSemantics)
        }

        configuration.planeDetection.insert(.horizontal)
        arView.session.run(configuration)
        defer { arView.session.delegate = self }

        arView.renderOptions.insert(.disableMotionBlur)
    }

    private func setUpGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapScene(_:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onSwipeScene(_:)))
        arView.addGestureRecognizer(panGestureRecognizer)
    }

}

// MARK: - actions

extension ARViewController {

    func spawn(_ type: ModelType) {
        let location = CGPoint(x: arView.frame.width / 2, y: arView.frame.height / 2)

        if let position = arView.realWorldVector(for: location) {
            guard let entity = Entity.createARModel(type: type, position: position) else { return }
            DispatchQueue.main.async(execute: {
                self.planeAnchor.addChild(entity)
                entity.getModelComponent()?.spawnAnimation()
                self.selectObject(entity.getModelComponent())
                self.arView.installGestures([.translation, .rotation], for: entity).forEach { entityGestureRecognizer in
                    entityGestureRecognizer.delegate = self
                }
            })
        }
    }

    func removeObject() {
        if let objectEntity = selectedObject {
            selectObject(nil)
            objectEntity.removeObject()
        }
    }

    func selectObject(_ ModelComponent: ModelComponent?) {
        if selectedObject == ModelComponent {
            if selectedObject?.isSelected() == true {
                selectedObject?.cancel()
            } else {
                selectedObject?.select()
            }
        } else {
            selectedObject?.cancel()
            ModelComponent?.select()
            selectedObject = ModelComponent
        }
        
        if let selectedObject = self.selectedObject {
            objectNameLabel.isHidden = false
            objectNameLabel.text = selectedObject.name
            removeButton.isHidden = false
            selectButton.isHidden = false
            selectButton.setTitle(selectedObject.isSelected() ? "deselect" : "select", for: .normal)
        } else {
            objectNameLabel.isHidden = true
            removeButton.isHidden = true
            selectButton.isHidden = true
        }
    }

    @objc private func onTapScene(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: arView)
        selectObject(hitObjectEntity(location: location)?.getModelComponent())
    }

    @objc private func onSwipeScene(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            let location = sender.location(in: arView)
            selectObject(hitObjectEntity(location: location)?.getModelComponent())

        default:
            break
        }
    }
    private func hitObjectEntity(location: CGPoint) -> Entity? {
        guard let entity = arView.entity(at: location) else { return nil }
        guard entity.isModelEntity() else { return nil }
        return entity
   }

}

// MARK: - ARSCNViewDelegate

extension ARViewController: ARSessionDelegate {

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        self.statusLabel.text = "didAdd anchors."
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        self.statusLabel.text = "didUpdate anchors."
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        self.statusLabel.text = "didRemove anchors."
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        camera?.transform = .init(matrix: frame.camera.transform)
    }

}

// MARK: - ARSCNViewDelegate

extension ARViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

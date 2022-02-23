//
//  ARViewController.swift
//  
//  
//  Created by ji-no on R 4/02/05
//  
//

import ARKit
import RealityKit

class ARViewController: UIViewController {
    @IBOutlet weak var arView: ARView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var objectNameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    
    var camera: AnchorEntity?
    lazy var planeAnchor: AnchorEntity = {
        let fishAnchor = AnchorEntity(world: .zero)
        arView.scene.addAnchor(fishAnchor)
        return fishAnchor
    }()

    var selectedObject: ModelComponent?
    var swipeStartObjectPosition: SIMD3<Float>?
    var swipeStartPosition: SIMD3<Float>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpScene()
    }

    @IBAction func onTapRemoveButton(_ sender: Any) {
        removeObject()
    }

    @IBAction func onTapSelectButton(_ sender: Any) {
        selectObject(selectedObject)
    }

}

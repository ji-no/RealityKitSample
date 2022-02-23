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
    @IBOutlet weak var memoryInfoLabel: UILabel!
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

    func showMemoryInfo() {
        // GB,MB,KB表記の文字列に変換
        let byteUnitStringConverted: (Int64) -> String = { size in
            ByteCountFormatter.string(fromByteCount: size, countStyle: ByteCountFormatter.CountStyle.binary)
        }

        //使用済みメモリ
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        var ret: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        let usedMemory = (ret == KERN_SUCCESS ? taskInfo.resident_size as UInt64 : 0)
                
        //フリーメモリ
        var size: mach_msg_type_number_t =
            UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size) as mach_msg_type_number_t
        var vmStatInfo = vm_statistics64()
        ret = withUnsafeMutablePointer(to: &vmStatInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                host_statistics64(mach_host_self(), host_flavor_t(HOST_VM_INFO64), $0, &size)
            }
        }
        let freeMemory = (ret == KERN_SUCCESS ? vm_size_t(vmStatInfo.free_count) * vm_kernel_page_size : 0)
        
        memoryInfoLabel.text = "Memory free: \(freeMemory * 100 / (UInt(usedMemory) + freeMemory)) %"
                
        print("Info: used: \(byteUnitStringConverted(Int64(usedMemory))), free: \(byteUnitStringConverted(Int64(freeMemory))), \(freeMemory * 100 / (UInt(usedMemory) + freeMemory)) %")
    }
}

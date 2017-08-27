//
//  ViewController.swift
//  ARKitDemo
//
//  Created by Eli on 2017/8/28.
//  Copyright © 2017年 Ely. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    // 创建一个节点(3D模型)
    var planeNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置代理
        sceneView.delegate = self
        
        // 显示一些数据，如fps,计时信息等
        sceneView.showsStatistics = true
        
        // 创建一个SCNScene，用于显示3d模型
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        // 节点名称设置为 飞机
        planeNode = scene.rootNode.childNode(withName: "shipMesh", recursively: true)
        // 将飞机变小
        planeNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
        // 向Z方向移动1单位 蓝色方向为Z
        planeNode.position = SCNVector3Make(0.0, 0.0, -1.0)
        // 自适应环境光照度，过渡更平滑
        sceneView.automaticallyUpdatesLighting = true;
        // 将加载了3d模型的SCNScene设置成ARSCNView的scene
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 为ARSCNView设置一个会话配置类(会话配置类，在配置类对象里设置会话如何将真实的设备运动映射到3D场景的坐标系统里，这里默认是使用重力)
        let configuration = ARWorldTrackingConfiguration()
        // 设置追踪平面类型为水平
        configuration.planeDetection = .horizontal
        // 自适应灯光
        configuration.isLightEstimationEnabled = true;
        // 开始
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 暂停
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate代理
    // 重要:当启用平面检测时，ARKit会为每个检测到的平面添加并更新锚点,为这些锚点添加可视化内容使用以下代理
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // This visualization covers only detected planes.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 创建SceneKit平面,依据它位置和范围展示节点
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        // 旋转
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        node.addChildNode(planeNode)
    }
    // MARK: - 添加点击事件
    // 点击节点，创建节点副本，得到hitTest，再次点击后添加新节点
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let results = sceneView.hitTest(touch.location(in: sceneView), types: .featurePoint)
        guard let anchor = results.first else { return }
        let hitPointTransform = SCNMatrix4(anchor.worldTransform)
        let hitPointPosition = SCNVector3Make(hitPointTransform.m41,
                                              hitPointTransform.m42,
                                              hitPointTransform.m43)
        let planeClone = planeNode.clone()
        planeClone.position = hitPointPosition
        sceneView.scene.rootNode.addChildNode(planeClone)
    }
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

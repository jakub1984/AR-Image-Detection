//
//  ViewController.swift
//  AR Image Detection
//
//  Created by Jakub Perich on 09/01/2019.
//  Copyright © 2019 Jakub Perich. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var falconNode: SCNNode?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        let falconScene = SCNScene(named: "art.scnassets/millenium-falcon.scn")
        falconNode = falconScene?.rootNode
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        if let imagesToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Trackable Images", bundle: Bundle.main) {
            configuration.trackingImages = imagesToTrack
            configuration.maximumNumberOfTrackedImages = 2
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let size = imageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: size.width, height: size.height)
            plane.cornerRadius = 0.005
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            if let falcon = falconNode {
                falcon.scale = SCNVector3(0.1,0.1,0.1)
                node.addChildNode(falcon)
            }
            
            
            
        }
        
        
        return node
    }

}

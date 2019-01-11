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
    var tieFighterNode: SCNNode?
    var imageNodes = [SCNNode]()
    var isClose = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        let falconScene = SCNScene(named: "art.scnassets/millenium-falcon.scn")
        let tieFighterScene = SCNScene(named: "art.scnassets/tie-fighter.scn")
        falconNode = falconScene?.rootNode
        tieFighterNode = tieFighterScene?.rootNode
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
            
            var shapeNode: SCNNode?
            
            switch imageAnchor.referenceImage.name {
            case StarshipType.falcon.rawValue:
                shapeNode = falconNode
                
            case StarshipType.tieFighter.rawValue:
                shapeNode = tieFighterNode
                
            default:
                break
            }
            
            
            guard let shapeNodeUnwrapped = shapeNode else {
                return nil
            }
            let rotateObjects = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10))
            shapeNodeUnwrapped.runAction(rotateObjects)
            shapeNodeUnwrapped.scale = SCNVector3(0.1,0.1,0.1)
            
            node.addChildNode(shapeNodeUnwrapped)
            imageNodes.append(node)
            return node

        }
        return nil
    }

    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if imageNodes.count == 2 {
            let positionA = SCNVector3ToGLKVector3(imageNodes[0].position)
            let positionB = SCNVector3ToGLKVector3(imageNodes[1].position)
            let distance = GLKVector3Distance(positionA, positionB)
            
            if distance < 0.15 {
            doTheBarrelRoll(node: imageNodes[0])
            doTheBarrelRoll(node: imageNodes[1])
            isClose = true
            } else {
                isClose = false
            }
            
            
            
        }
    }

    func doTheBarrelRoll(node: SCNNode){
        if isClose {return}
        let shapeNode = node.childNodes[1]
        
        let closeAction = SCNAction.rotateBy(x: -2 * .pi, y: 0, z: 0, duration: 1)
        
        shapeNode.runAction(closeAction)
        
    }

    
    enum StarshipType : String {
        case falcon = "pas"
        case tieFighter = "keyboard"
    }

}

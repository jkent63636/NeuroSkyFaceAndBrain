//
//  ViewController.swift
//  NeuroSkyFaceAndBrain
//
//  Created by Joshua Kent on 3/22/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    //face geometry
    var faceGeo: ARSCNFaceGeometry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //Make sure face tracking is supported
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
        
        //NeuroSky - Set Up device
        let mwDevice = MWMDevice()
        mwDevice.scanDevice()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines

        return node
    }
    
    //This updates the AR
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            
            faceGeo = faceGeometry
            
            //updates face mesh
            faceGeometry.update(from: faceAnchor.geometry)
                
            //calls expression function to determine facial expressions
            expression(anchor: faceAnchor)
        
            DispatchQueue.main.async {
                //Put any object you want to update based on tracking here
                
            }
        }
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
    
    func expression(anchor: ARFaceAnchor) {
        let tongue = anchor.blendShapes[.tongueOut]
        
        if tongue?.decimalValue ?? 0.0 > 0.1 {
            print("Tongue Out!")
        }
    }


}


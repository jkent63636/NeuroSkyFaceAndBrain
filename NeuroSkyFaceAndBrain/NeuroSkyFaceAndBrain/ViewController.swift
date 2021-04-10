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
    
    //labels for face coeffecients
    @IBOutlet weak var eyeBlinkLeft: UILabel!
    @IBOutlet weak var eyeBlinkRight: UILabel!
    @IBOutlet weak var mouthLeft: UILabel!
    @IBOutlet weak var mouthRight: UILabel!
    @IBOutlet weak var mouthSmileLeft: UILabel!
    @IBOutlet weak var mouthSmileRight: UILabel!
    @IBOutlet weak var browOuterUpLeft: UILabel!
    @IBOutlet weak var browOuterUpRight: UILabel!
    
    var eyeBlinkLeftValue = 0.0
    var eyeBlinkRightValue = 0.0
    var mouthLeftValue = 0.0
    var mouthRightValue = 0.0
    var mouthSmileLeftValue = 0.0
    var mouthSmileRightValue = 0.0
    var browOuterUpLeftValue = 0.0
    var browOuterUpRightValue = 0.0
    
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
                
                self.eyeBlinkLeft.text = "Eye Blink Left: \(self.eyeBlinkLeftValue)"
                self.eyeBlinkRight.text = "Eye Blink Right: \(self.eyeBlinkRightValue)"
                
                self.mouthLeft.text = "Mouth Left: \(self.mouthLeftValue)"
                self.mouthRight.text = "Mouth Right: \(self.mouthRightValue)"
                
                self.mouthSmileLeft.text = "Mouth Smile Left: \(self.mouthSmileLeftValue)"
                self.mouthSmileRight.text = "Mouth Smile Right: \(self.mouthSmileRightValue)"
                
                self.browOuterUpLeft.text = "BrowOuter Up Left: \(self.browOuterUpLeftValue)"
                self.browOuterUpRight.text = "BrowOuter Up Right: \(self.browOuterUpRightValue)"
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
        //Both eye linking
        let eyeBlinkLeft = anchor.blendShapes[.eyeBlinkLeft]
        let eyeBlinkRight = anchor.blendShapes[.eyeBlinkRight]
        
        //Both lips of mouth treacking
        let mouthLeft = anchor.blendShapes[.mouthLeft]
        let mouthRight = anchor.blendShapes[.mouthRight]
        
        //Both side of mouth smiling tracking
        let mouthSmileLeft = anchor.blendShapes[.mouthSmileLeft]
        let mouthSmileRight = anchor.blendShapes[.mouthSmileRight]
        
        //Both outer brow tracking
        let browOuterUpLeft = anchor.blendShapes[.browOuterUpLeft]
        let browOuterUpRight = anchor.blendShapes[.browOuterUpRight]
        
        //a ?? b > c.a = coefficient from 0 (neutral) to 1 (max movement), b = default value, and c min to identify movement
        
        if eyeBlinkLeft?.decimalValue ?? 0.0 > 0.25 {
            print("Left eye blink")
            self.eyeBlinkLeftValue = (((eyeBlinkLeft?.doubleValue ?? 0.0)*100).rounded())/100
        }
        if eyeBlinkRight?.decimalValue ?? 0.0 > 0.25 {
            print("Right eye blink")
            self.eyeBlinkRightValue = (((eyeBlinkRight?.doubleValue ?? 0.0)*100).rounded())/100
        }
        
        if mouthLeft?.decimalValue ?? 0.0 > 0.25 {
            print("Mouth left")
            self.mouthLeftValue = (((mouthLeft?.doubleValue ?? 0.0)*100).rounded())/100
        }
        if mouthRight?.decimalValue ?? 0.0 > 0.25 {
            print("Mouth right")
            self.mouthRightValue = (((mouthRight?.doubleValue ?? 0.0)*100).rounded())/100
        }
        
        if mouthSmileLeft?.decimalValue ?? 0.0 > 0.25 {
            print("Mouth Smile left")
            self.mouthSmileLeftValue = (((mouthSmileLeft?.doubleValue ?? 0.0)*100).rounded())/100
        }
        if mouthSmileRight?.decimalValue ?? 0.0 > 0.25 {
            print("Mouth Smile right")
            self.mouthSmileRightValue = (((mouthSmileRight?.doubleValue ?? 0.0)*100).rounded())/100
        }
        
        if browOuterUpLeft?.decimalValue ?? 0.0 > 0.25 {
            print("Brow Outer left")
            self.browOuterUpLeftValue = (((browOuterUpLeft?.doubleValue ?? 0.0)*100).rounded())/100
        }
        if browOuterUpRight?.decimalValue ?? 0.0 > 0.25 {
            print("Brow Outer right")
            self.browOuterUpRightValue = (((browOuterUpLeft?.doubleValue ?? 0.0)*100).rounded())/100
        }
    }


}


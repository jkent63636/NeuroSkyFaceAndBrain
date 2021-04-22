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
    
    //label to show differenc in facial weakness
    @IBOutlet weak var differenceFacialWeakness: UILabel!
    
    //Labels for NeuroSky brain waves
    @IBOutlet weak var deltaWaves: UILabel!
    @IBOutlet weak var thetaWaves: UILabel!
    @IBOutlet weak var alphaWaves: UILabel!
    
    
    //Values should be inserted in the following order: mouthSmileLeft, mouthSmileRight, eyeBlinkLeft, eyeBlinkRight, mouthLeft, mouthRight, browOuterUpLeft, browOuterUpRight
    var facialValues = [0.0 , 0.0, 0.0 , 0.0, 0.0 , 0.0, 0.0 , 0.0]
    
    //label to prompt facial movements
    @IBOutlet weak var facialWeaknessLabel: UILabel!
    
    //list to hold facial weakness difference values. 10 is default
    var facialDifferences = [["Smile", "Blink", "Move Lips", "Raise Eyebrows"], [10.0, 10.0, 10.0, 10.0]]
    
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
                
                self.eyeBlinkLeft.text = "Eye Blink Left: \(self.facialValues[2])"
                self.eyeBlinkRight.text = "Eye Blink Right: \(self.facialValues[3])"
                
                self.mouthLeft.text = "Mouth Left: \(self.facialValues[4])"
                self.mouthRight.text = "Mouth Right: \(self.facialValues[5])"
                
                self.mouthSmileLeft.text = "Mouth Smile Left: \(self.facialValues[0])"
                self.mouthSmileRight.text = "Mouth Smile Right: \(self.facialValues[1])"
                
                self.browOuterUpLeft.text = "BrowOuter Up Left: \(self.facialValues[6])"
                self.browOuterUpRight.text = "BrowOuter Up Right: \(self.facialValues[7])"
                
                //should be able to update brain wave labels here once that is implemented
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
//            print("Left eye blink")
            self.facialValues[2] = (((eyeBlinkLeft?.doubleValue ?? 0.0)*100).rounded())/100
        }
        if eyeBlinkRight?.decimalValue ?? 0.0 > 0.25 {
//            print("Right eye blink")
            self.facialValues[3] = (((eyeBlinkRight?.doubleValue ?? 0.0)*100).rounded())/100
        }
        
        if mouthLeft?.decimalValue ?? 0.0 > 0.25 {
//            print("Mouth left")
            self.facialValues[4] = (((mouthLeft?.doubleValue ?? 0.0)*100).rounded())/100
        }
        if mouthRight?.decimalValue ?? 0.0 > 0.25 {
//            print("Mouth right")
            self.facialValues[5] = (((mouthRight?.doubleValue ?? 0.0)*100).rounded())/100
        }
        
        if mouthSmileLeft?.decimalValue ?? 0.0 > 0.25 {
//            print("Mouth Smile left")
            self.facialValues[0] = (((mouthSmileLeft?.doubleValue ?? 0.0)*100).rounded())/100
        }
        if mouthSmileRight?.decimalValue ?? 0.0 > 0.25 {
//            print("Mouth Smile right")
            self.facialValues[1] = (((mouthSmileRight?.doubleValue ?? 0.0)*100).rounded())/100
        }
        
        if browOuterUpLeft?.decimalValue ?? 0.0 > 0.25 {
//            print("Brow Outer left")
            self.facialValues[6] = (((browOuterUpLeft?.doubleValue ?? 0.0)*100).rounded())/100
        }
        if browOuterUpRight?.decimalValue ?? 0.0 > 0.25 {
//            print("Brow Outer right")
            self.facialValues[7] = (((browOuterUpLeft?.doubleValue ?? 0.0)*100).rounded())/100
        }
    }
    
    //track which facial weakness is being prompted
    var facialDifferenceIndex = 0
    
    //index of facial values
    var facialValueIndex = 0
    
    //user needs to be doing action WHEN they click button
    @IBAction func facialWeaknessTest(_ sender: UIButton) {
        facialDifferences[1][facialDifferenceIndex] = self.facialValues[facialValueIndex] - self.facialValues[facialValueIndex + 1]
        print(facialDifferences[1][facialDifferenceIndex])
        
        differenceFacialWeakness.text = "Difference: \(facialDifferences[1][facialDifferenceIndex])"
        
        facialDifferenceIndex += 1
        facialValueIndex += 2
        
        if facialDifferenceIndex < 4 {
            facialWeaknessLabel.text = (facialDifferences[0][facialDifferenceIndex] as! String)
        } else {
            facialWeaknessLabel.text = (facialDifferences[0][0] as! String)
            
            facialDifferenceIndex = 0
            facialValueIndex = 0
        }
    }
}


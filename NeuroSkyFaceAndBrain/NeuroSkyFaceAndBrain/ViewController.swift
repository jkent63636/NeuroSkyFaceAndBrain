//
//  ViewController.swift
//  NeuroSkyFaceAndBrain
//
//  Created by Joshua Kent on 3/22/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Set Up device
        let mwDevice = MWMDevice()
        mwDevice.scanDevice()
        
    }


}


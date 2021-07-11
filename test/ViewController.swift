//
//  ViewController.swift
//  Tuner_example
//
//  Created by Vladimir Gorbunov on 11.07.2021.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var frequancyLabel: UILabel!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var frequancySlider: UISlider!
    @IBOutlet weak var delaySlider: UISlider!
    
    
    let tone = Tuner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup tuner
        tone.run()
        
        frequancyLabel.text = String(frequancySlider.value * 1000)
        delayLabel.text = String(delaySlider.value * 1000)
    }

    @IBAction func start(_ sender: UIButton) {
        tone.start()
    }
    @IBAction func stop(_ sender: UIButton) {
        tone.stop()
    }
    @IBAction func frequency(_ sender: UISlider) {
        frequancyLabel.text = String(frequancySlider.value * 1000)
        tone.frequency = sender.value * 1000
    }
    @IBAction func delay(_ sender: UISlider) {
        delayLabel.text = String(delaySlider.value * 1000)
        tone.delay = Int(sender.value) * 1000
    }
}


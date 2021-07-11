//
//  Tuner.swift
//  Tuner_example
//
//  Created by Vladimir Gorbunov on 11.07.2021.
//

import Foundation
import AVFoundation

class Tuner {
    
    ///  Delay between wavebeeps in Frames (defaut: 0)
    ///  Frequncy in Hertz (defaut: 440)
    ///  Amplitude between 0.0 and 1.0 (default: 1.0)
    
    var delay = 0
    var frequency: Float = 1200.0
    let amplitude: Float = 1.0
    
    let twoPi = 2 * Float.pi
    let signal = { (phase: Float) -> Float in
        return sin(phase)
    }
    
    ///Wave examples
//    let whiteNoise = { (phase: Float) -> Float in
//        return ((Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX)) * 2 - 1)
//    }
//
//    let sawtoothUp = { (phase: Float) -> Float in
//        return 1.0 - 2.0 * (phase * (1.0 / twoPi))
//    }
//
//    let sawtoothDown = { (phase: Float) -> Float in
//        return (2.0 * (phase * (1.0 / twoPi))) - 1.0
//    }
//
//    let square = { (phase: Float) -> Float in
//        if phase <= Float.pi {
//            return 1.0
//        } else {
//            return -1.0
//        }
//    }
//    let triangle = { (phase: Float) -> Float in
//        var value = (2.0 * (phase * (1.0 / twoPi))) - 1.0
//        if value < 0.0 {
//            value = -value
//        }
//        return 2.0 * (value - 0.5)
//    }
    
    
    var engine: AVAudioEngine
    var mainMixer: AVAudioMixerNode
    var output: AVAudioOutputNode
    var outputFormat: AVAudioFormat
    let sampleRate: Float
    
    // Use output format for input but reduce channel count to 1
    var inputFormat : AVAudioFormat?
    
    var currentPhase: Float = 0
    
    // The interval by which we advance the phase each frame.
    var phaseIncrement: Float = 0
    
    init() {
        engine = AVAudioEngine()
        mainMixer = engine.mainMixerNode
        output = engine.outputNode
        outputFormat = output.inputFormat(forBus: 0)
        sampleRate = Float(outputFormat.sampleRate)
        inputFormat = AVAudioFormat(commonFormat: outputFormat.commonFormat,
                                    sampleRate: outputFormat.sampleRate,
                                    channels: 1,
                                    interleaved: outputFormat.isInterleaved)
    }
    
    func run() {
        
        var buzerFrameCounter = 0
        var silentFrameCounter = 0
        var tempValue: Float = 0.0
        
        let srcNode = AVAudioSourceNode { [unowned self] _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
               
                if silentFrameCounter < delay {
                    if buzerFrameCounter != 0 {buzerFrameCounter = 0}
                    tempValue = 0
                    silentFrameCounter += 1
                } else {
                    phaseIncrement = (twoPi / sampleRate) * frequency
                    tempValue = signal(currentPhase) * amplitude
                    currentPhase += phaseIncrement
                    if currentPhase >= 0 {
                        currentPhase -= twoPi
                    }
                    if currentPhase < 0.0 {
                        currentPhase += twoPi
                    }
                    buzerFrameCounter += 1
                    //set buzer lenght in frames
                    if buzerFrameCounter > 7000 {
                        silentFrameCounter = 0
                    }
                }
                
                // Set the same value on all channels (due to the inputFormat we have only 1 channel though).
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = tempValue
                    
                }
            }
            return noErr
        }
        
        engine.attach(srcNode)
        engine.connect(srcNode, to: mainMixer, format: inputFormat)
        
        engine.connect(mainMixer, to: output, format: outputFormat)
        mainMixer.outputVolume = 1
    }
    
    func start() {
        do {
            try engine.start()
        } catch {
            print("Could not start engine: \(error)")
        }
    }
    
    func stop() {
        engine.pause()
    }
}

//
//  AKAudioPlayer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Simple audio playback class
public struct AKAudioPlayer: AKNode {
    
    private var audioFileBuffer: AVAudioPCMBuffer
    private var internalPlayer: AVAudioPlayerNode
    public var avAudioNode: AVAudioNode
    
    /// Boolean indicating whether or not to loop the playback
    public var looping = false
    
    /** Output Volume (Default 1) */
    public var volume: Double = 1.0 {
        didSet {
            if volume < 0 {
                volume = 0
            }
            internalPlayer.volume = Float(volume)
        }
    }
    
    /** Pan (Default Center = 0) */
    public var pan: Double = 0.0 {
        didSet {
            if pan < -1 {
                pan = -1
            }
            if pan > 1 {
                pan = 1
            }
            internalPlayer.pan = Float(pan)
        }
    }
    
    /// Initialize the player
    public init(_ file: String) {
        let url = NSURL.fileURLWithPath(file, isDirectory: false)
        let audioFile = try! AVAudioFile(forReading: url)
        let audioFormat = audioFile.processingFormat
        let audioFrameCount = UInt32(audioFile.length)
        audioFileBuffer = AVAudioPCMBuffer(PCMFormat: audioFormat, frameCapacity: audioFrameCount)
        try! audioFile.readIntoBuffer(audioFileBuffer)
        
        internalPlayer = AVAudioPlayerNode()
        AKManager.sharedInstance.engine.attachNode(internalPlayer)

        let mixer = AVAudioMixerNode()
        AKManager.sharedInstance.engine.attachNode(mixer)
        AKManager.sharedInstance.engine.connect(internalPlayer, to: mixer, format: audioFormat)
        self.avAudioNode = mixer

        internalPlayer.scheduleBuffer(
            audioFileBuffer,
            atTime: nil,
            options: .Loops,
            completionHandler: nil)
        internalPlayer.volume = 1.0
    }
    
    /// Start playback
    public func play() {
        if !internalPlayer.playing {
            var options: AVAudioPlayerNodeBufferOptions = AVAudioPlayerNodeBufferOptions.Interrupts
            if looping {
                options = .Loops
            }
            internalPlayer.scheduleBuffer(audioFileBuffer, atTime: nil, options: options, completionHandler: nil)
        }
        internalPlayer.play()
    }
    
    /// Pause playback
    public func pause() {
        internalPlayer.pause()
    }

    /// Stop playback
    public func stop() {
        internalPlayer.stop()
    }
}

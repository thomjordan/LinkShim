//
//  AbletonLinkResponder.swift
//  AbletonLinkShim
//
//  Created by Thom Jordan on 8/28/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Foundation
import AbletonLinkShimCppToObjC


public class AbletonLinkResponder : ALinkShimDelegate {
    
    public var callback : ((Double, Double) -> ())?
    
    public func linkShimPropertiesUpdated(_ linkShim: Any!) {
        guard let shim = linkShim as? ALinkShim else {
            print("LinkShim not recognized...")
            return
        }
        guard let properties = getBeatWithBPM(shim) else { return }
        print("A Link property has been updated. Current state is now :")
        print("    enabled = \(shim.enabled())")
        print("    tempo   = \(properties.bpm)")
        
        callback?(properties.beat, properties.bpm) 
        print("Link properties updated: beat = \(properties.beat); BPM = \(properties.bpm)")
    }
    
    public func linkShimNumPeersUpdated(_ linkShim: Any!) {
        guard let shim = linkShim as? ALinkShim else {
            print("LinkShim not recognized...")
            return
        }
        print("Link number of peers updated: numberOfPeers = \(shim.numberOfPeers())")
    }
    
    public func getBeatWithBPM(_ shim: ALinkShim) -> (beat: Double, bpm: Double)? {
        
        var beat : Double =  0.0
        var bpm  : Double = 270.0
        
        let result = shim.getBeat(&beat, andBPM: &bpm)
        
        if result {
            print("Successfully retrieved BEAT:BPM from Ableton Link. BEAT: \(beat) ; BPM: \(bpm)")
            return (beat: beat, bpm: bpm)
        }
        else      {
            print("Could not retrieve BEAT:BPM from Ableton Link.")
            return nil
        }
    }
    
    public func setCallback(_ cb: @escaping (Double, Double) -> () ) {
        self.callback = cb
    }
}


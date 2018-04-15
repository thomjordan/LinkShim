//
//  AbletonLinkClient.swift
//  AbletonLinkShim
//
//  Created by Thom Jordan on 8/28/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Foundation
import AbletonLinkShimCppToObjC


public class AbletonLinkClient {
    
    public let aLinkShim      : ALinkShim
    public let aLinkResponder : AbletonLinkResponder
    
    public init() {
        aLinkShim          = ALinkShim()
        aLinkResponder     = AbletonLinkResponder()
        aLinkShim.delegate = aLinkResponder
    }
    
    public func setUpdatingCallback(_ cb: @escaping (Double, Double) -> () ) {
        aLinkResponder.callback = cb
    }
    
    public func invokeUpdatingCallback(beat: Double, bpm: Double) {
        aLinkResponder.callback?(beat, bpm)
    }
    
    public func setEnabled(_ n: Bool) {
        aLinkShim.setEnabled(n)
    }
    
    public func getBeatWithBPM() -> (beat: Double, bpm: Double)? {
        return aLinkResponder.getBeatWithBPM(aLinkShim)
    }
    
    public func setBeat(_ beat:Double, andBPM bpm:Double, byForce f:Bool = false) {
        aLinkShim.setBeat(beat, andBPM: bpm, byForce: f)
    }
    
}



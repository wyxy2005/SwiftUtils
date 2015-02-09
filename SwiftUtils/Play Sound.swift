//
//  Play Sound.swift
//  Clepsydra
//
//  Created by Alexandre on 03/02/15.
//  Copyright (c) 2015 ACT Productions. All rights reserved.
//

import Foundation
import AudioToolbox

public class PlaySound {
    private var soundID: SystemSoundID = 0
    
    public init(file: String, vibrate: Bool = true) {
        AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath: file), &soundID)
        play(vibrate)
    }
    
    public init(vibrate: Bool = true) {
        // Magic number for the standard sms tone
        // From here: http://iphonedevwiki.net/index.php/AudioServices
        soundID = 1007
        play(vibrate)
    }
    
    private func play(vibrate: Bool) {
        if vibrate { AudioServicesPlayAlertSound(soundID) }
        else { AudioServicesPlaySystemSound(soundID) }
    }
    
    deinit {
        AudioServicesDisposeSystemSoundID(soundID)
    }
}

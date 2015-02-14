//
//  Play Sound.swift
//

import Foundation
import AudioToolbox

/**
A very simple class to play sounds on iOS. Stops the sound when deinited.
*/
public class PlaySound {
    private var soundID: SystemSoundID = 0
    
    /**
    Play from a sound file
    
    :param: file    The complete file path
    :param: vibrate Whether the device should vibrate while playing
    */
    public init(file: String, vibrate: Bool = true) {
        AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath: file), &soundID)
        play(vibrate)
    }
    
    /**
    Play the standard tri-tone alert
    
    :param: vibrate Whether the device should vibrate while playing
    */
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

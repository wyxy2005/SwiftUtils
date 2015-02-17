//
//  ViewController.swift
//  iCloudTest
//
//  Created by Alexandre on 17/02/15.
//  Copyright (c) 2015 ACT Productions. All rights reserved.
//

import UIKit
import SwiftUtils

var UserDefaults = UserDefaultsClass()

extension UDKeys {
    static let MyText = UDKey<String>("MyText", "default text", true)
    static let UseCloud = UDKey<Bool>("UseCloud---", false, false)
}

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cloudSwitch: UISwitch!
    
    var obj: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloudSwitch.on = UserDefaults.get(UDKeys.UseCloud)
        UserDefaults.iCloudSync = UserDefaults.get(UDKeys.UseCloud)
        
        UserDefaultsClass.Signals.cloudStorageUpdatedDiskStorage
            .listen(self) { _ in self.loadChanges(); println("signal called!") }
            .filter { $0 === UserDefaults }
        
        loadChanges()
    }

    @IBAction func iCloudSwitch(sender: UISwitch) {
        UserDefaults.iCloudSync = sender.on
        UserDefaults.set(UDKeys.UseCloud, sender.on)
    }
    @IBAction func saveChanges() {
        UserDefaults.set(UDKeys.MyText, textField.text)
    }
    @IBAction func loadChanges() {
        textField.text = UserDefaults.get(UDKeys.MyText)
    }
}

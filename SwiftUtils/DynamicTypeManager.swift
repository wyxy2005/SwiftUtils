//
//  DynamicTypeManager.swift
//

// Note: adapted from https://github.com/bignerdranch/BNRDynamicTypeManager

import UIKit

/**
A class deigned to make Dynamic Type easier.
*/
public class DynamicTypeManagerClass {
    private let elementTable = NSMapTable.weakToStrongObjectsMapTable()
    private let notification: NSObjectProtocol?
    private class InfoTuple: NSObject {
        let keyPath: String
        let textStyle: String
        init(_ k: String, _ s: String) {
            keyPath = k
            textStyle = s
        }
    }
    
    public init() {
        notification = NSNotificationCenter.defaultCenter().addObserverForName(UIContentSizeCategoryDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [unowned self] _ in
            let enumerator = self.elementTable.keyEnumerator()
            while let element = enumerator.nextObject() as NSObject? {
                let tuple = self.elementTable.objectForKey(element) as InfoTuple
                element.setValue(UIFont.preferredFontForTextStyle(tuple.textStyle), forKeyPath: tuple.keyPath)
            }
        }
    }
    
    public func watch(label: UILabel, textStyle: String? = nil) {
        watch(label, fontKeypath: "font", textStyle: textStyle)
    }
    public func watch(button: UIButton, textStyle: String? = nil) {
        watch(button, fontKeypath: "titleLabel.font", textStyle: textStyle)
    }
    public func watch(textField: UITextField, textStyle: String? = nil) {
        watch(textField, fontKeypath: "font", textStyle: textStyle)
    }
    public func watch(textView: UITextView, textStyle: String? = nil) {
        watch(textView, fontKeypath: "font", textStyle: textStyle)
    }
    public func watch(object: AnyObject, fontKeypath: String, var textStyle: String? = nil) {
        if textStyle == nil {
            if let font = object.valueForKey(fontKeypath) as? UIFont {
                textStyle = textStyleMatchingFont(font)
            }
        }
        
        if let style = textStyle {
            object.setValue(UIFont.preferredFontForTextStyle(style), forKeyPath: fontKeypath)
            elementTable.setObject(InfoTuple(fontKeypath, style), forKey: object)
        }
    }
    
    public func textStyleMatchingFont(font: UIFont) -> String? {
        for style in [UIFontTextStyleBody, UIFontTextStyleCaption1, UIFontTextStyleCaption2, UIFontTextStyleFootnote, UIFontTextStyleHeadline, UIFontTextStyleSubheadline] {
            if font == UIFont.preferredFontForTextStyle(style) {
                return style
            }
        }
        
        return nil
    }
}

public let DynamicTypeManager = DynamicTypeManagerClass() // Singleton

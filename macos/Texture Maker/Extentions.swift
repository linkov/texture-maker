//
//  Extentions.swift
//  Texture Maker
//
//  Created by Alex Linkov on 5/13/21.
//

import Foundation
import Cocoa


extension Notification.Name {
    // Notifications
    static let didReceiveTextureCallbackNotification = Notification.Name("didReceiveTextureCallbackNotification")
}


extension NSView {

    func bringSubviewToFront(_ view: NSView) {
            var theView = view
            self.sortSubviews({(viewA,viewB,rawPointer) in
                let view = rawPointer?.load(as: NSView.self)

                switch view {
                case viewA:
                    return ComparisonResult.orderedDescending
                case viewB:
                    return ComparisonResult.orderedAscending
                default:
                    return ComparisonResult.orderedSame
                }
            }, context: &theView)
    }

}
extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
            let prop: [NSBitmapImageRep.PropertyKey: Any] = [
                .fallbackBackgroundColor: NSColor.black
                   ]
        
        return bitmapImage.representation(using: .jpeg, properties: prop)
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}


extension URL {
    var isDirectory: Bool {
       return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}

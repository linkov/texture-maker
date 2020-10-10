//
//  AppDelegate.swift
//  Texture Maker
//
//  Created by Alex Linkov on 10/7/20.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NSApp.appearance = NSAppearance(named: .darkAqua)
        NSApp.windows.first!.titlebarAppearsTransparent = true
        NSApp.windows.first!.backgroundColor = .black
        NSApp.windows.first!.titleVisibility = .hidden
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    

}


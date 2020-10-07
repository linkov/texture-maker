//
//  ViewController.swift
//  Texture Maker
//
//  Created by Alex Linkov on 10/7/20.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var resultImageView: NSImageView!
    @IBOutlet weak var imageWell: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageWell.isEditable = true
        
        resultImageView.layer?.backgroundColor = NSColor.black.cgColor
        resultImageView.wantsLayer = true
        resultImageView.layer?.borderColor = NSColor.blue.cgColor
        resultImageView.layer?.borderWidth = 4
        resultImageView.layer?.cornerRadius = 4
    
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .black
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    
    @IBAction func imageChanged(_ sender: NSImageView) {
        if let image = sender.image{
          print("image changed")
        }
    }
    
    
//    @IBAction func chooseInitialImage(_ sender: Any) {
//
//
//
//
//        let openPanel = NSOpenPanel()
//        openPanel.allowsMultipleSelection = false
//        openPanel.canChooseDirectories = false
//        openPanel.canCreateDirectories = false
//        openPanel.canChooseFiles = true
//        openPanel.allowedFileTypes = ["jpg","png","pdf","pct", "bmp", "tiff"]
//        let i = openPanel.runModal()
//        if(i == NSApplication.ModalResponse.OK){
//
//            let str = openPanel.url?.path
//
//            let result = begin_with_filepath(str, 256)
//            let swift_result = String(cString: result!)
//            filepath_free(UnsafeMutablePointer(mutating: result))
//            print(swift_result)
//
//            let rectIMG = NSImage(contentsOf: openPanel.url!)
//            //imageView1.image = rectIMG
//
//
//
//        }
//
//    }


}


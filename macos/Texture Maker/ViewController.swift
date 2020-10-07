//
//  ViewController.swift
//  Texture Maker
//
//  Created by Alex Linkov on 10/7/20.
//

import Cocoa
import SYFlatButton

class ViewController: NSViewController {
    
    var selectedImage: NSImage?
    var selectedImagePath: String?

    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var selectFileButton: NSButton!
    @IBOutlet weak var fastTextureButton: NSButton!
    @IBOutlet weak var tileSizeField: NSTextField!
    @IBOutlet weak var outSizeField: NSTextField!
    
    
    @IBOutlet weak var paramsBox: NSBox!
    @IBOutlet weak var resultImageView: NSImageView!
    @IBOutlet weak var imageWell: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageWell.isEditable = false
        
        resultImageView.wantsLayer = true
        resultImageView.layer?.backgroundColor = NSColor.black.cgColor
        
        resultImageView.layer?.borderColor = NSColor.darkGray.cgColor
        resultImageView.layer?.borderWidth = 4
        resultImageView.layer?.cornerRadius = 4
        
        self.fastTextureButton.isEnabled = false
        self.fastTextureButton.layer?.opacity = 0.4
        
        imageWell.wantsLayer = true
        imageWell.layer?.backgroundColor = NSColor.black.cgColor
    
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .black
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(didReceiveTextureCallback), name: Notification.Name("didReceiveTextureCallbackNotification"), object: nil)
        
        
        register_callback { (res) in
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("didReceiveTextureCallbackNotification"), object: res! as String)
            
        }
        
        
    }
    
    
    
    @objc func didReceiveTextureCallback(note: NSNotification)  {
        
        let successStr = note.object
        
        if (successStr as! String == "success") {
            
            let imageResult = NSImage(contentsOf: URL(fileURLWithPath: "result.jpg", isDirectory: false))
            
            DispatchQueue.main.async { [self] in
                resultImageView.image = imageResult
            }
           
            
        } else {
            
            print("Texture error")
        }
        
        DispatchQueue.main.async { [self] in
            
            self.progressBar.stopAnimation(nil)
            self.progressBar.isHidden = true
            self.fastTextureButton.isEnabled = true
            self.fastTextureButton.layer?.opacity = 1.0
        }

        
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewWillAppear() {
        
 
        
        let connector1 = LineView(frame:  self.view.frame, fromView: imageWell, toView: paramsBox)
        self.view.addSubview(connector1)

        let connector3 = LineView(frame:  self.view.frame, fromView: paramsBox, toView: resultImageView)
        self.view.addSubview(connector3)

      
//        self.view.bringSubviewToFront(imageWell)
//        self.view.bringSubviewToFront(paramsBox)
        
        
        self.view.displayIfNeeded()
        self.view.bringSubviewToFront(resultImageView)
        self.view.bringSubviewToFront(paramsBox)
        self.view.bringSubviewToFront(imageWell)
        self.view.bringSubviewToFront(selectFileButton)
    }
    
    
    
    
    //MARK: Actions
    

    @IBAction func fastDidClick(_ sender: Any) {
        
        
        self.progressBar.isHidden = false
        self.progressBar.startAnimation(nil)
        
        if (selectedImage == nil || selectedImagePath == nil) {
            return
        }
        
        var size = 250
        if (tileSizeField.stringValue.count > 0) {
            size = Int( tileSizeField.stringValue )!
        }
        
        var outSize = 512
        if (outSizeField.stringValue.count > 0) {
            outSize = Int( outSizeField.stringValue )!
        }
        
        performTextureOp(size: size, outSize: outSize)
        
    }
    
    
    
    @IBAction func imageChanged(_ sender: NSImageView) {
//        if let image = sender.image{
//            selectedImage = image
//        }
    }
    
    func performTextureOp(size: Int, outSize: Int) {

        
        fastTextureButton.isEnabled = false
        self.fastTextureButton.layer?.opacity = 0.4
        
        begin_with_filepath(selectedImagePath!, Int32(size), Int32(outSize))
    
    }
    
    
    @IBAction func chooseInitialImage(_ sender: Any) {

        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["jpg","png","pdf","pct", "bmp", "tiff"]
        let i = openPanel.runModal()
        if(i == NSApplication.ModalResponse.OK){

            let str = openPanel.url?.path
            let rectIMG = NSImage(contentsOf: openPanel.url!)
            self.imageWell.image = rectIMG
            self.selectedImage = rectIMG
            self.selectedImagePath = str
            self.view.bringSubviewToFront(imageWell)
            self.fastTextureButton.isEnabled = true
            self.fastTextureButton.layer?.opacity = 1.0

        }

    }


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

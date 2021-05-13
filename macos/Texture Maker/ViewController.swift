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

    @IBOutlet weak var moreDetailsCheckbox: NSButton!
    @IBOutlet weak var saveButton: SYFlatButton!
    @IBOutlet weak var isRandomizedCheckbox: NSButton!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var selectFileButton: NSButton!
    @IBOutlet weak var fastTextureButton: NSButton!
    @IBOutlet weak var tileSizeField: NSTextField!
    @IBOutlet weak var outSizeField: NSTextField!
    
    
    @IBOutlet weak var paramsBox: NSBox!
    @IBOutlet weak var resultImageView: NSImageView!
    @IBOutlet weak var imageWell: NSImageView!
    
    //MARK: Lifecycle
    
    deinit {
        
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: Notification.Name.didReceiveTextureCallbackNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(didReceiveTextureCallback), name: Notification.Name.didReceiveTextureCallbackNotification, object: nil)
        

        setupUI()
        registerForRustNotification()

        
        
    }
    
    override func viewWillAppear() {
        
 
        
        let connector1 = LineView(frame:  self.view.frame, fromView: imageWell, toView: paramsBox)
        self.view.addSubview(connector1)

        let connector3 = LineView(frame:  self.view.frame, fromView: paramsBox, toView: resultImageView)
        self.view.addSubview(connector3)
        
        self.view.displayIfNeeded()
        
        self.view.bringSubviewToFront(resultImageView)
        self.view.bringSubviewToFront(paramsBox)
        self.view.bringSubviewToFront(imageWell)
        self.view.bringSubviewToFront(selectFileButton)
        
        selectFileButton.wantsLayer = true
        selectFileButton.layer?.opacity = 0.6
    }
    
    func setupUI() {
        
        self.imageWell.isEditable = false
        
        resultImageView.wantsLayer = true
        resultImageView.layer?.backgroundColor = NSColor.black.cgColor
        
        resultImageView.layer?.borderColor = NSColor.darkGray.cgColor
        resultImageView.layer?.borderWidth = 4
        resultImageView.layer?.cornerRadius = 4
        
        self.tileSizeField.focusRingType = .none
        self.outSizeField.focusRingType = .none
        
        self.fastTextureButton.isEnabled = false
        self.fastTextureButton.layer?.opacity = 0.4
        
        self.saveButton.isEnabled = false
        self.saveButton.layer?.opacity = 0.4
        
        imageWell.wantsLayer = true
        imageWell.layer?.backgroundColor = NSColor.black.cgColor
    
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .black
    }
    

    //MARK: Rust lib
    
    func registerForRustNotification()  {
        
        register_callback { (res) in
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name.didReceiveTextureCallbackNotification, object: res! as String)
            
        }
    }
    
    func performTextureOp(size: Int, outSize: Int) {

        let isRandom = isRandomizedCheckbox.state == .on;
        let isDetailed = isRandomizedCheckbox.state == .on;
        
        fastTextureButton.isEnabled = false
        self.fastTextureButton.layer?.opacity = 0.4
        
        begin_with_filepath(selectedImagePath!, Int32(size), Int32(outSize), isRandom, isDetailed)
    
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
            
            
            self.saveButton.isEnabled = true;
            self.saveButton.layer?.opacity = 1.0;
            
        }

        
        
        
    }



    //MARK: Actions


    
    @IBAction func saveDidClick(_ sender: Any) {
        
        if (resultImageView.image != nil) {
            saveImage(image: resultImageView.image!)
        }
    }
    
    @IBAction func generateDidClick(_ sender: Any) {
        
        if (selectedImage == nil || selectedImagePath == nil) {
            return
        }
        
        self.progressBar.isHidden = false
        self.progressBar.startAnimation(nil)
        
        
        var size = 250
        if (tileSizeField.stringValue.count > 0 && tileSizeField.intValue != 0) {
            size = Int(tileSizeField.intValue)
        } else {
            tileSizeField.intValue = Int32(size)
        }
        
        var outSize = 512
        if (outSizeField.stringValue.count > 0  && outSizeField.intValue != 0) {
            outSize = Int(outSizeField.intValue)
        } else {
            outSizeField.intValue = Int32(outSize)
        }
        
        performTextureOp(size: size, outSize: outSize)
        
    }
    


    
    @IBAction func chooseInitialImage(_ sender: Any) {

        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["jpeg","jpg","png","pdf","pct", "bmp", "tiff"]
        let i = openPanel.runModal()
        if(i == NSApplication.ModalResponse.OK){

            let str = openPanel.url?.path
            let rectIMG = NSImage(contentsOf: openPanel.url!)
            self.imageWell.image = rectIMG
            self.selectedImage = rectIMG
            self.selectedImagePath = str

            self.fastTextureButton.isEnabled = true
            self.fastTextureButton.layer?.opacity = 1.0

        }

    }
    
    
    func saveImage(image: NSImage) {
        
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "result.jpeg"
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        savePanel.begin { (result) in
            if result == NSApplication.ModalResponse.OK {
                guard let url = savePanel.url else { return }

                let data = image.pngData
                do {
                    try data?.write(to: url, options: .atomicWrite)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }



}


//
//  ViewController.swift
//  getframescenekit
//
//  Created by macos on 18.05.2020.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var lines : [Int]?
    var maxRefImages : Int = 5
    var markerPos : [[Float]] =  Array(repeating: Array(repeating: 0, count: 0), count: 5)
    var trackedImages : Set<ARReferenceImage> = Set<ARReferenceImage>()
    var inputImageSize : [String] = [String]()
    var inputImageCount : Int?
    var refImageName : Int = 0
    
    var cannyFirstSliderValue : Float = 30
    var cannySecondSliderValue : Float = 75
    var houghThresholdSliderValue : Float = 20
    var houghMinLengthSliderValue : Float = 650
    var houghMaxGapSliderValue : Float = 150
    
    var cannyFirstLabel : UILabel?
    var cannySecondLabel : UILabel?
    var houghThresholdLabel : UILabel?
    var houghMinLengthLabel : UILabel?
    var houghMaxGapLabel : UILabel?
    
    var cylinderDataField : UILabel?
    
    var imagePicker = UIImagePickerController()
    var imagePicker2 = UIImagePickerController()
    var refImagePicked : Bool = false
    var refImage : [UIImage] = [UIImage]()
    var textureImage : [UIImage] = [UIImage]()
    
    var heightOfView : CGFloat?
    var widthOfRes : CGFloat?
    var timer : Timer?
    var updateCV : Bool = false
    var currHeight : Int = 0
    var currRadius : Int = 0
    var smallerCylinderCounter : Int = 0
    var smallerCylinderCounterLimit : Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        heightOfView = sceneView.bounds.size.height
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(enableUpdateCV), userInfo: nil, repeats: true)
        
        // 5 sliders are needed
        // First, canny's first treshold
        let cannyFirstRect = CGRect(x: 15, y: 625, width: 140, height: 10)
        let cannyFirstSlider = UISlider(frame: cannyFirstRect)
        cannyFirstSlider.maximumValue = 255
        cannyFirstSlider.minimumValue = 0
        cannyFirstSlider.value = cannyFirstSliderValue
        cannyFirstSlider.isContinuous = true
        // add the label for slider
        let cannyFirstLabelRect = CGRect(x: 160, y: 625, width: 55, height: 15)
        cannyFirstLabel = UILabel(frame: cannyFirstLabelRect)
        cannyFirstLabel!.text = String(format: "%.0f", cannyFirstSliderValue)
        // add the laber describing slider
        let cannyFirstDescLabelRect = CGRect(x: 10, y: 600, width: 150, height: 15)
        let cannyFirstDescLabel = UILabel(frame: cannyFirstDescLabelRect)
        cannyFirstDescLabel.text = "First threshold for the hysteresis"
        cannyFirstDescLabel.adjustsFontSizeToFitWidth = true
        
        cannyFirstSlider.addTarget(self, action: #selector(cannyFirstSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(cannyFirstSlider)
        self.view.addSubview(cannyFirstLabel!)
        self.view.addSubview(cannyFirstDescLabel)
        
        // canny's second treshold
        let cannySecondRect = CGRect(x: 15, y: 675, width: 140, height: 10)
        let cannySecondSlider = UISlider(frame: cannySecondRect)
        cannySecondSlider.maximumValue = 255
        cannySecondSlider.minimumValue = 0
        cannySecondSlider.value = cannySecondSliderValue
        cannySecondSlider.isContinuous = true
        // add the label for slider
        let cannySecondLabelRect = CGRect(x: 160, y: 675, width: 55, height: 15)
        cannySecondLabel = UILabel(frame: cannySecondLabelRect)
        cannySecondLabel!.text = String(format: "%.0f", cannySecondSliderValue)
        // add the laber describing slider
        let cannySecondDescLabelRect = CGRect(x: 10, y: 650, width: 150, height: 15)
        let cannySecondDescLabel = UILabel(frame: cannySecondDescLabelRect)
        cannySecondDescLabel.text = "Second threshold for the hysteresis"
        cannySecondDescLabel.adjustsFontSizeToFitWidth = true
        
        cannySecondSlider.addTarget(self, action: #selector(cannySecondSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(cannySecondSlider)
        self.view.addSubview(cannySecondLabel!)
        self.view.addSubview(cannySecondDescLabel)
        
        // hough's treshold
        let houghThresholdRect = CGRect(x: 210, y: 575, width: 140, height: 10)
        let houghThresholdSlider = UISlider(frame: houghThresholdRect)
        houghThresholdSlider.maximumValue = 50
        houghThresholdSlider.minimumValue = 0
        houghThresholdSlider.value = houghThresholdSliderValue
        houghThresholdSlider.isContinuous = true
        // add the label for slider
        let houghThresholdLabelRect = CGRect(x: 355, y: 575, width: 55, height: 15)
        houghThresholdLabel = UILabel(frame: houghThresholdLabelRect)
        houghThresholdLabel!.text = String(format: "%.0f", houghThresholdSliderValue)
        // add the laber describing slider
        let houghThresholdDescLabelRect = CGRect(x: 205, y: 550, width: 150, height: 15)
        let houghThresholdDescLabel = UILabel(frame: houghThresholdDescLabelRect)
        houghThresholdDescLabel.text = "Accumulator threshold"
        houghThresholdDescLabel.adjustsFontSizeToFitWidth = true
        
        houghThresholdSlider.addTarget(self, action: #selector(houghThresholdSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(houghThresholdSlider)
        self.view.addSubview(houghThresholdLabel!)
        self.view.addSubview(houghThresholdDescLabel)
        
        // hough's min line length
        let houghMinLengthRect = CGRect(x: 210, y: 625, width: 140, height: 10)
        let houghMinLengthSlider = UISlider(frame: houghMinLengthRect)
        houghMinLengthSlider.maximumValue = 1000
        houghMinLengthSlider.minimumValue = 0
        houghMinLengthSlider.value = houghMinLengthSliderValue
        houghMinLengthSlider.isContinuous = true
        // add the label for slider
        let houghMinLengthLabelRect = CGRect(x: 355, y: 625, width: 55, height: 15)
        houghMinLengthLabel = UILabel(frame: houghMinLengthLabelRect)
        houghMinLengthLabel!.text = String(format: "%.0f", houghMinLengthSliderValue)
        // add the laber describing slider
        let houghMinLengthDescLabelRect = CGRect(x: 205, y: 600, width: 150, height: 15)
        let houghMinLengthDescLabel = UILabel(frame: houghMinLengthDescLabelRect)
        houghMinLengthDescLabel.text = "Minimum line length"
        houghMinLengthDescLabel.adjustsFontSizeToFitWidth = true
        
        houghMinLengthSlider.addTarget(self, action: #selector(houghMinLengthSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(houghMinLengthSlider)
        self.view.addSubview(houghMinLengthLabel!)
        self.view.addSubview(houghMinLengthDescLabel)
        
        // hough's max line gap
        let houghMaxGapRect = CGRect(x: 210, y: 675, width: 140, height: 10)
        let houghMaxGapSlider = UISlider(frame: houghMaxGapRect)
        houghMaxGapSlider.maximumValue = 255
        houghMaxGapSlider.minimumValue = 0
        houghMaxGapSlider.value = houghMaxGapSliderValue
        houghMaxGapSlider.isContinuous = true
        // add the label for slider
        let houghMaxGapLabelRect = CGRect(x: 355, y: 675, width: 55, height: 15)
        houghMaxGapLabel = UILabel(frame: houghMaxGapLabelRect)
        houghMaxGapLabel!.text = String(format: "%.0f", houghMaxGapSliderValue)
        // add the laber describing slider
        let houghMaxGapDescLabelRect = CGRect(x: 205, y: 650, width: 150, height: 15)
        let houghMaxGapDescLabel = UILabel(frame: houghMaxGapDescLabelRect)
        houghMaxGapDescLabel.text = "Maximum allowed gap"
        houghMaxGapDescLabel.adjustsFontSizeToFitWidth = true
        
        houghMaxGapSlider.addTarget(self, action: #selector(houghMaxGapSliderChanged(sender:)),
                                   for: UIControl.Event.valueChanged)
        
        self.view.addSubview(houghMaxGapSlider)
        self.view.addSubview(houghMaxGapLabel!)
        self.view.addSubview(houghMaxGapDescLabel)
        
        let lineMapButtonRect = CGRect(x: 15, y: 560, width: 140, height: 40)
        let lineMapButton = UIButton(frame: lineMapButtonRect)
        lineMapButton.backgroundColor = UIColor.darkGray
        lineMapButton.setTitle("Stop Redrawing", for: .normal)
        lineMapButton.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)

        self.view.addSubview(lineMapButton)
        
        // add the label describing cylinder dimensions
        let cylinderDataFieldRect = CGRect(x: 10, y: 10, width: 100, height: 100)
        cylinderDataField = UILabel(frame: cylinderDataFieldRect)
        cylinderDataField!.text = ""
        cylinderDataField!.adjustsFontSizeToFitWidth = true
        
        self.view.addSubview(cylinderDataField!)
            
        // Ask to get images
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = false
            
            // Ask to get the reference image
            present(self.imagePicker, animated: true, completion: {
                
                self.imagePicker2.delegate = self
                self.imagePicker2.sourceType = .savedPhotosAlbum
                self.imagePicker2.allowsEditing = false
                
                //Present the instruction controller
                self.imagePicker.present(self.imagePicker2, animated: true, completion: {
                    
                    let refImageCount = UIAlertController(title: "Reference Image Count", message: "Maximum \(self.maxRefImages)", preferredStyle: .alert)
                    var inputTextFieldCount = UITextField()

                    refImageCount.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) -> Void in
                        
                        // -1 because we will always get one texture-refImage combo from here
                        self.inputImageCount = Int(inputTextFieldCount.text!)! - 1
                        
                        if (self.inputImageCount! < 0 || self.inputImageCount! > self.maxRefImages - 1) {
                            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                        }
                        
                        let refImageSize = UIAlertController(title: "Reference Image Size In cm", message: "", preferredStyle: .alert)
                        var inputTextField = UITextField()

                        refImageSize.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) -> Void in
                            
                            self.inputImageSize.append(inputTextField.text!)
                        }))
                        refImageSize.addTextField(configurationHandler: {(textField: UITextField!) in
                            
                             textField.placeholder = ""
                             inputTextField = textField
                         })
                        
                        self.imagePicker2.present(refImageSize, animated: true, completion: nil)
                    }))
                    refImageCount.addTextField(configurationHandler: {(textField: UITextField!) in
                        
                         textField.placeholder = ""
                         inputTextFieldCount = textField
                     })
                    
                    self.imagePicker2.present(refImageCount, animated: true, completion: nil)
                })
            })
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if (!refImagePicked) {
            
            refImage.append(info[.originalImage] as! UIImage)
            
            imagePicker2.dismiss(animated: true, completion: nil)
            
            guard let inputImgSize = NumberFormatter().number(from: inputImageSize[refImageName]) else { return }
            
            let refimage = ARReferenceImage((refImage[refImageName].cgImage)!,
                                            orientation: .up,
                                            physicalWidth: CGFloat(truncating: inputImgSize) / 100)
            
            refimage.validate { (Error) in
                if Error != nil {
                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                }
            }
            
            refimage.name = "\(refImageName)"
            refImageName += 1
            
            trackedImages.insert(refimage)
            
            if (inputImageCount! <= 0) {
            
                let configuration = ARWorldTrackingConfiguration()
                widthOfRes = configuration.videoFormat.imageResolution.width
                
                configuration.detectionImages = trackedImages
                // User may want to track multiple of the same reference images
                configuration.maximumNumberOfTrackedImages = 10
                
                sceneView.session.run(configuration, options: [])
                
            }

            refImagePicked = true
        }
        else {
            
            refImagePicked = false
            
            textureImage.append(info[.originalImage] as! UIImage)
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            // Repeat asking for referanceimages/textures until count is 0
            if (inputImageCount! > 0) {
                inputImageCount! -= 1
                
                if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                    
                    self.imagePicker.delegate = self
                    self.imagePicker.sourceType = .savedPhotosAlbum
                    self.imagePicker.allowsEditing = false
                    
                    // Ask to get the reference image
                    present(self.imagePicker, animated: true, completion: {
                        
                        self.imagePicker2.delegate = self
                        self.imagePicker2.sourceType = .savedPhotosAlbum
                        self.imagePicker2.allowsEditing = false
                        
                        //Present the instruction controller
                        self.imagePicker.present(self.imagePicker2, animated: true, completion: {
                            
                            let refImageSize = UIAlertController(title: "Reference Image Size In cm", message: "", preferredStyle: .alert)
                            var inputTextField = UITextField()

                            refImageSize.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) -> Void in
                                
                                self.inputImageSize.append(inputTextField.text!)
                            }))
                            refImageSize.addTextField(configurationHandler: {(textField: UITextField!) in
                                
                                 textField.placeholder = ""
                                 inputTextField = textField
                             })
                            
                            self.imagePicker2.present(refImageSize, animated: true, completion: nil)
                        })
                    })
                }
            }
        }
        
    }
    
    @objc func cannyFirstSliderChanged(sender: UISlider) {
        cannyFirstSliderValue = sender.value
        cannyFirstLabel!.text = String(format: "%.0f", sender.value)
    }
    
    @objc func cannySecondSliderChanged(sender: UISlider) {
        cannySecondSliderValue = sender.value
        cannySecondLabel!.text = String(format: "%.0f", sender.value)
    }
    
    @objc func houghThresholdSliderChanged(sender: UISlider) {
        houghThresholdSliderValue = sender.value
        houghThresholdLabel!.text = String(format: "%.0f", sender.value)
    }
    
    @objc func houghMinLengthSliderChanged(sender: UISlider) {
        houghMinLengthSliderValue = sender.value
        houghMinLengthLabel!.text = String(format: "%.0f", sender.value)
    }
    
    @objc func houghMaxGapSliderChanged(sender: UISlider) {
        houghMaxGapSliderValue = sender.value
        houghMaxGapLabel!.text = String(format: "%.0f", sender.value)
    }
    
    @objc func enableUpdateCV() {
        updateCV = true
    }
    
    @objc func buttonAction(sender: UIButton!) {
        
        if (timer!.isValid) {
            timer!.invalidate()
            updateCV = false
            sender.setTitle("Start Redrawing", for: .normal)
            
            // Update the text label
            cylinderDataField!.text = "r = \(CGFloat(Double(currRadius) / 100.0)) l = \(CGFloat(Double(currHeight) / 100.0))"
        }
        else {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(enableUpdateCV), userInfo: nil, repeats: true)
            sender.setTitle("Stop Redrawing", for: .normal)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension ViewController : ARSessionDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARImageAnchor {
            
            let imganc = anchor as! ARImageAnchor
            let width = imganc.referenceImage.physicalSize.width * imganc.estimatedScaleFactor
            let height = imganc.referenceImage.physicalSize.width * imganc.estimatedScaleFactor
            
            // A plane that covers the whole image to signify that it is found
            let planeOverImage = SCNPlane(width: CGFloat(width), height: CGFloat(height))
            planeOverImage.firstMaterial?.diffuse.contents = UIColor.green
            let planeOverImageNode = SCNNode(geometry: planeOverImage)
            planeOverImageNode.eulerAngles.x = -.pi / 2
            
            // Left edge of the image
            let leftedge = SCNSphere(radius: 0.005)
            let leftedgeNode = SCNNode(geometry: leftedge)
            leftedgeNode.position.x += Float(width) / 2
            
            //Right edge of the image
            let rightedge = SCNSphere(radius: 0.005)
            let rightedgeNode = SCNNode(geometry: rightedge)
            rightedgeNode.position.x -= Float(width) / 2
            
            // Find the difference between how many pixels are
            // between left and right edge to determine pixels per cm
            
            // Add an empty node that will be turned into cylinders when data is available
            let cylinderNode = SCNNode()
            cylinderNode.name = "cylinder"
            
            node.addChildNode(planeOverImageNode)
            node.addChildNode(leftedgeNode)
            node.addChildNode(rightedgeNode)
            node.addChildNode(cylinderNode)
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        if updateCV && anchor is ARImageAnchor {
                
            updateCV = false;
            
            let imganc = anchor as! ARImageAnchor
            
            let imgNum = Int(imganc.referenceImage.name!)!
            
            let multiplier : Double = Double(heightOfView! / widthOfRes!)
            
            lines = OpenCVWrapper.getAllLines(Double(cannyFirstSliderValue),
                                              cannySecondThreshold: Double(cannySecondSliderValue),
                                              houghThreshold: Double(houghThresholdSliderValue),
                                              houghMinLength: Double(houghMinLengthSliderValue),
                                              houghMaxGap: Double(houghMaxGapSliderValue),
                                              image: sceneView.session.currentFrame!.capturedImage) as? [Int]
            
            // Add the current positions of the markers
            markerPos[imgNum] = [Float]()
            for childNodes in sceneView.node(for: anchor)!.childNodes {
                let ballpos = childNodes.worldPosition
                let temp = sceneView.projectPoint(SCNVector3(ballpos.x, ballpos.y, ballpos.z))
                // contents are: [0][1] -> image plane, also the point where the image center is
                // [2][3] -> leftEdge, left side of the image
                // [4][5] -> rightEdge, right side of the image
                markerPos[imgNum].append(temp.x)
                markerPos[imgNum].append(temp.y)
            }

            // Now call for the closest left and right lines
            // [0] through [3] height of the cylinder
            // [4] [5] is the point that intersects the left line
            // [6] [7] is the point that intersects the right line
            let points = OpenCVWrapper.getCylinderLines(Int32(Double(markerPos[imgNum][0]) / multiplier),
                                                        y: Int32(Double(markerPos[imgNum][1]) / multiplier),
                                                        lines: lines!) as! [Int]
            
            // means, no lines were found as possible matches
            if (points[0] == 0) {
                return
            }
             
            // Length of the marker is predetermined,
            let markerDiffx = markerPos[imgNum][4] - markerPos[imgNum][2]
            let MarkerDiffy = markerPos[imgNum][5] - markerPos[imgNum][3]
            let pixelsToCm = pow(Double(pow(markerDiffx, 2) + pow(MarkerDiffy, 2)), 0.5) / (Double(inputImageSize[imgNum])! * Double(imganc.estimatedScaleFactor))
             
            // Check which line is longer, set that as the height of the cylinder
            let heightDiffx = (Double(String(points[2]))! * multiplier) - (Double(String(points[0]))! * multiplier)
            let heightDiffy = (Double(String(points[3]))! * multiplier) - (Double(String(points[1]))! * multiplier)
            let heightLength = pow(pow(heightDiffx, 2) + pow(heightDiffy, 2), 0.5) / pixelsToCm
             
            // Get the distance between left and right lines to determine the
            // radiues of the cylinder
            let linesDiffx = (Double(String(points[6]))! * multiplier) - (Double(String(points[4]))! * multiplier)
            let linesDiffy = (Double(String(points[7]))! * multiplier) - (Double(String(points[5]))! * multiplier)
            let radius = pow(pow(linesDiffx, 2) + pow(linesDiffy, 2), 0.5) / (2 * pixelsToCm)
             
            // [0] is the length of the cylinder
            // [1] is how high the marker is
            var longerLine : [Double] = [Double]()
            
            longerLine.append(heightLength)

            // the lower point is x2y2
            let diffx = (Double(String(points[2]))! * multiplier) - (Double(String(points[4]))! * multiplier)
            let diffy = (Double(String(points[3]))! * multiplier) - (Double(String(points[5]))! * multiplier)
            let heightFromGround = pow(pow(diffx, 2) + pow(diffy, 2), 0.5) / pixelsToCm
            longerLine.append(heightFromGround - heightLength / 2)

            let height = Int(longerLine[0] + 1)
            let rad = Int(radius + 1)
            
            if (rad > currRadius || height > currHeight || smallerCylinderCounter >= smallerCylinderCounterLimit) {
                                
                currRadius = rad > currRadius ? rad : currRadius
                currHeight = height > currHeight ? height : currHeight
                if (smallerCylinderCounter >= smallerCylinderCounterLimit) {
                    currRadius = rad
                    currHeight = height
                }
                smallerCylinderCounter = 0
                
                // Edit the cylinder node
                for childnode in node.childNodes {
                    if (childnode.name == "cylinder") {
                        let cylinder = SCNCylinder(radius: CGFloat(Double(currRadius) / 100.0), height: CGFloat(Double(currHeight) / 100.0))
                        cylinder.firstMaterial?.diffuse.contents = textureImage[imgNum].cgImage
                        childnode.geometry = cylinder
                        childnode.position.y = -1 * Float(radius / 100.0)
                        childnode.position.z = Float(longerLine[1] / 100.0)
                        childnode.eulerAngles.x = -.pi / 2
                    }
                }
            }
            else {
                smallerCylinderCounter += 1
            }
            
        }
    }
    
}

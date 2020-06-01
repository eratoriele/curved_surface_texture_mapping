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
    
    var imagePicker = UIImagePickerController()
    var imagePicker2 = UIImagePickerController()
    var refImagePicked : Bool = false
    var refImage : [UIImage] = [UIImage]()
    var textureImage : [UIImage] = [UIImage]()
    
    var heightOfView : CGFloat?
    var widthOfRes : CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        heightOfView = sceneView.bounds.size.height
        
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
        cannyFirstLabel!.text = "\(cannyFirstSliderValue)"
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
        cannySecondLabel!.text = "\(cannySecondSliderValue)"
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
        houghThresholdLabel!.text = "\(houghThresholdSliderValue)"
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
        houghMinLengthLabel!.text = "\(houghMinLengthSliderValue)"
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
        houghMaxGapLabel!.text = "\(houghMaxGapSliderValue)"
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
        lineMapButton.setTitle("Draw Cylinder", for: .normal)
        lineMapButton.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)

        self.view.addSubview(lineMapButton)
        
        let lineButtonRect = CGRect(x: 15, y: 505, width: 140, height: 40)
        let lineButton = UIButton(frame: lineButtonRect)
        lineButton.backgroundColor = UIColor.darkGray
        lineButton.setTitle("Draw Lines", for: .normal)
        lineButton.addTarget(self, action: #selector(lineButton(sender:)), for: .touchUpInside)

        self.view.addSubview(lineButton)
            
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

            print(inputImageCount!)
            print(inputImageSize)
            
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
    
    @objc func buttonAction(sender: UIButton!) {
        
        var anchorNode : SCNNode?
        
        // Remove sublayers from previous frame
        if (sceneView.layer.sublayers != nil) {
            for subl in sceneView.layer.sublayers! {
                if subl is CAShapeLayer {
                    subl.removeFromSuperlayer()
                }
            }
        }
        
        for anc in sceneView.session.currentFrame!.anchors {
            if anc is ARImageAnchor {
                let imganc = anc as! ARImageAnchor
                
                // If image isn't tracked, it isnt in the camera
                if (!imganc.isTracked) {
                    continue
                }
                let imgNum = Int(imganc.referenceImage.name!)!
                
                print(markerPos[imgNum])
                
                anchorNode = sceneView.node(for: anc)

                 let multiplier : Double = Double(heightOfView! / widthOfRes!)
                 
                 // Now call for the closest left and right lines
                 // [0] through [3] is left line, [4] through [7] is right line
                 // [8] [9] is the point that intersects the left line
                 // [10] [11] is the point that intersects the right line
                
                 // Now call for the closest left and right lines
                 // [0] through [3] is left line endpoints, [4] slope of left line, [5] c of left line,
                 // [6] through [9] is right line endpoints, [10] slope of right line, [11] c of right line,
                 // [12] [13] is the point that intersects the left line
                 // [14] [15] is the point that intersects the right line
                 let points = OpenCVWrapper.getCylinderLines(Int32(Double(markerPos[imgNum][0]) / multiplier),
                                                             y: Int32(Double(markerPos[imgNum][1]) / multiplier),
                                                             lines: lines!) as! [Int]
                
                 // means, no lines were found as possible matches
                 if (points[0] == 0) {
                     print("no lines found")
                     return
                 }
                 
                 // Length of the marker is predetermined,
                 let markerDiffx = markerPos[imgNum][4] - markerPos[imgNum][2]
                 let MarkerDiffy = markerPos[imgNum][5] - markerPos[imgNum][3]
                 let pixelsToCm = pow(Double(pow(markerDiffx, 2) + pow(MarkerDiffy, 2)), 0.5) / Double(inputImageSize[imgNum])!
                 
                 // Check which line is longer, set that as the height of the cylinder
                 let leftDiffx = (Double(String(points[2]))! * multiplier) - (Double(String(points[0]))! * multiplier)
                 let leftDiffy = (Double(String(points[3]))! * multiplier) - (Double(String(points[1]))! * multiplier)
                 let leftLength = pow(pow(leftDiffx, 2) + pow(leftDiffy, 2), 0.5) / pixelsToCm
                 
                 let rightDiffx = (Double(String(points[8]))! * multiplier) - (Double(String(points[6]))! * multiplier)
                 let rightDiffy = (Double(String(points[9]))! * multiplier) - (Double(String(points[7]))! * multiplier)
                 let rightLength = pow(pow(rightDiffx, 2) + pow(rightDiffy, 2), 0.5) / pixelsToCm
                 
                 // Get the distance between left and right lines to determine the
                 // radiues of the cylinder
                 let linesDiffx = (Double(String(points[14]))! * multiplier) - (Double(String(points[12]))! * multiplier)
                 let linesDiffy = (Double(String(points[15]))! * multiplier) - (Double(String(points[13]))! * multiplier)
                 let radius = pow(pow(linesDiffx, 2) + pow(linesDiffy, 2), 0.5) / (2 * pixelsToCm)
                 
                 // [0] is the length of the cylinder
                 // [1] is how high the marker is
                 var longerLine : [Double] = [Double]()
                 if (rightLength < leftLength) {
                     longerLine.append(leftLength)
                     // the lower point is x1y1
                     if (Double(String(points[3]))! < Double(String(points[1]))!) {
                         let diffx = (Double(String(points[0]))! * multiplier) - (Double(String(points[12]))! * multiplier)
                         let diffy = (Double(String(points[1]))! * multiplier) - (Double(String(points[13]))! * multiplier)
                         let heightFromGround = pow(pow(diffx, 2) + pow(diffy, 2), 0.5) / pixelsToCm
                         longerLine.append(heightFromGround - leftLength / 2)
                     }
                     // the lower point is x2y2
                     else {
                         let diffx = (Double(String(points[2]))! * multiplier) - (Double(String(points[12]))! * multiplier)
                         let diffy = (Double(String(points[3]))! * multiplier) - (Double(String(points[13]))! * multiplier)
                         let heightFromGround = pow(pow(diffx, 2) + pow(diffy, 2), 0.5) / pixelsToCm
                         longerLine.append(heightFromGround - leftLength / 2)
                     }
                 }
                 else {
                     longerLine.append(rightLength)
                     // the lower point is x1y1
                     if (Double(String(points[7]))! < Double(String(points[5]))!) {
                         let diffx = (Double(String(points[6]))! * multiplier) - (Double(String(points[14]))! * multiplier)
                         let diffy = (Double(String(points[7]))! * multiplier) - (Double(String(points[15]))! * multiplier)
                         let heightFromGround = pow(pow(diffx, 2) + pow(diffy, 2), 0.5) / pixelsToCm
                         longerLine.append(heightFromGround - rightLength / 2)
                     }
                     // the lower point is x2y2
                     else {
                         let diffx = (Double(String(points[8]))! * multiplier) - (Double(String(points[14]))! * multiplier)
                         let diffy = (Double(String(points[9]))! * multiplier) - (Double(String(points[15]))! * multiplier)
                         let heightFromGround = pow(pow(diffx, 2) + pow(diffy, 2), 0.5) / pixelsToCm
                         longerLine.append(heightFromGround - rightLength / 2)
                     }
                 }
                 
                 let height = Int(longerLine[0] + 1)
                 let rad = Int(radius + 1)
                 
                 let cylinder = SCNCylinder(radius: CGFloat(Double(rad) / 100.0), height: CGFloat(Double(height) / 100.0))
                 cylinder.firstMaterial?.diffuse.contents = textureImage[imgNum].cgImage
                 let cylinderNode = SCNNode(geometry: cylinder)
                 cylinderNode.position.y -= Float(radius / 100.0)
                 cylinderNode.position.z += Float(longerLine[1] / 100.0)
                 cylinderNode.eulerAngles.x = -.pi / 2
                 
                 anchorNode?.addChildNode(cylinderNode)
            }
        }
        
    }
    
    @objc func lineButton(sender: UIButton!) {
        
        for anchor in sceneView.session.currentFrame!.anchors {
            if anchor is ARImageAnchor {
                
                let imganc = anchor as! ARImageAnchor
                
                // If image isn't tracked, it isnt in the camera
                if (!imganc.isTracked) {
                    continue
                }
                
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
                
                // Remove sublayers from previous frame
                if (sceneView.layer.sublayers != nil) {
                    for subl in sceneView.layer.sublayers! {
                        if subl is CAShapeLayer {
                            subl.removeFromSuperlayer()
                        }
                    }
                }
            
                if (lines!.count == 0) {
                    return
                }
                for i in 0...lines!.count/4 - 1 {
                    let line = UIBezierPath()
                    
                    line.move(to: CGPoint(x: Double(String(lines![i*4]))! * multiplier,
                                          y: Double(String(lines![i*4 + 1]))! * multiplier))
                    line.addLine(to: CGPoint(x: Double(String(lines![i*4 + 2]))! * multiplier,
                                             y: Double(String(lines![i*4 + 3]))! * multiplier))
                    line.close()
                        
                    let shapeLayer = CAShapeLayer()
                    shapeLayer.path = line.cgPath
                    shapeLayer.opacity = 1
                    shapeLayer.strokeColor = UIColor(red: CGFloat(arc4random()) / CGFloat(UInt32.max),
                                                     green: CGFloat(arc4random()) / CGFloat(UInt32.max),
                                                     blue: CGFloat(arc4random()) / CGFloat(UInt32.max),
                                                     alpha: 1).cgColor
                    shapeLayer.lineWidth = 3
                    
                    sceneView.layer.addSublayer(shapeLayer)
                }
            }
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
            
            node.addChildNode(planeOverImageNode)
            node.addChildNode(leftedgeNode)
            node.addChildNode(rightedgeNode)
        }
        
    }
    
}

import UIKit
import AVFoundation

class ReadingScannerVC: UIViewController {


    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageView2: UIImageView!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var boxRect: CGRect!
    var boxView: UIView!
    var image: UIImage?
    var imgOverlay: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        setupCamera()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        } catch let error  {
            print("Error unable to initialize back camera: \(error.localizedDescription)")
        }
    }
    
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        
        let cameraView = UIView(frame: view.bounds)
        self.view.addSubview(cameraView)
        
        videoPreviewLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(videoPreviewLayer)
        
        addOverlayWithBox(to: cameraView)
        addCaptureButton(to: cameraView)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func addOverlayWithBox(to view: UIView) {
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(overlayView)
        
        let boxSize = CGSize(width: 200, height: 100 )
        boxRect = CGRect(x: (view.bounds.width - boxSize.width) / 2,
                             y: (view.bounds.height - boxSize.height) / 2,
                             width: boxSize.width,
                             height: boxSize.height)
        
        let path = UIBezierPath(rect: view.bounds)
        path.append(UIBezierPath(rect: boxRect).reversing())
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        overlayView.layer.mask = maskLayer
        
        boxView = UIView(frame: boxRect)
        boxView.layer.borderColor = UIColor.white.cgColor
        boxView.layer.borderWidth = 2
        view.addSubview(boxView)
        imgOverlay = overlayView
    }
    
    func addCaptureButton(to view: UIView) {
        let captureButton = UIButton(type: .system)
        captureButton.setTitle("Capture", for: .normal)
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.backgroundColor = .systemBlue
        captureButton.layer.cornerRadius = 5
        captureButton.frame = CGRect(x: (view.bounds.width - 100) / 2, y: view.bounds.height - 100, width: 100, height: 50)
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
    }
    
    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func stopCameraSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
            DispatchQueue.main.async {
                self?.videoPreviewLayer.removeFromSuperlayer()
                
                // Cameraview has button and box sublayered onto it. Remove it here
                self?.view.subviews.last?.removeFromSuperview()
            }
        }
    }
    
    func processImage() {
        print("Processing!!!!")
        
        
        
        if let target1 = imageView.captureImage() {
            if let processedImage = target1.processedImage() {
                imageView2.image = processedImage
                print("Size: \(processedImage.size)")
            } else {
                imageView2.image = target1
                print("Size: \(target1.size)")
            }
        }
        
        
        
        
        
    }
    
    
}

extension UIImageView {
    func captureImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { _ in
            layer.render(in: UIGraphicsGetCurrentContext()!)
        }
    }
}

extension ReadingScannerVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let preImage = UIImage(data: imageData) else {
            print("Error capturing photo: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        
//        let imageSize = preImage.size
//        let boxSize = CGSize(width: 600, height: 120)
//        
//        // Define the rectangle in the center of the image
//        let rect = CGRect(
//            x: (imageSize.width - boxSize.width) / 2,
//            y: (imageSize.height - boxSize.height) / 2 ,
//            width: boxSize.width,
//            height: boxSize.height
//        )
        
    
//        let croppedImage = cropToBounds(image: preImage)
//        let croppedImage = centerCropImage(preImage, to: imageView.bounds.size)
//        print("Image cropped successfully")
        
        image = preImage
        print("Size1: \(image?.size)")
        
//        else {
//            print("Failed to crop image")
//            
//            image = preImage
//        }
    
        
//        UIGraphicsBeginImageContextWithOptions(imageSize, false, preImage.scale)
//        guard let context = UIGraphicsGetCurrentContext() else {
//            print("Failed to create graphics context")
//            DispatchQueue.main.async { [weak self] in
//                self?.imageView.image = preImage
//            }
//            stopCameraSession()
//            return
//        }
//        
//        // Draw the original image
//        preImage.draw(at: .zero)
//        
//        // Draw the green box
//        context.setStrokeColor(UIColor.green.cgColor)
//        context.setLineWidth(5)
//        context.stroke(rect)
//        
//        // Create a new image from the context
//        let imageWithBox = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        // Ensure the image is not nil
//        guard let finalImage = imageWithBox else {
//            print("Failed to create image with box")
//            DispatchQueue.main.async { [weak self] in
//                self?.imageView.image = preImage
//            }
//            stopCameraSession()
//            return
//        }
//        
//        print("Image with box created successfully")
//        
//        image = finalImage

        
    
        print("Stopping session")
        
        stopCameraSession()
        
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = self?.image
            self?.image = self?.imageView.image
            self?.processImage()
        }
    }
}

extension UIImage {
    func processedImage() -> UIImage? {
        guard let ciImage = CIImage(image: self) else {
            return nil
        }
        
        let context = CIContext(options: nil)
        
        // Apply filters
        let filteredImage = applyFilters(to: ciImage, in: context)
        
        // Convert the filtered image back to UIImage
        if let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
    
    private func applyFilters(to ciImage: CIImage, in context: CIContext) -> CIImage {
        // Create a CIFilter chain
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(4.5, forKey: kCIInputRadiusKey)
        
//        let edgeWorkFilter = CIFilter(name: "CIEdgeWork")
//        edgeWorkFilter?.setValue(blurFilter?.outputImage, forKey: kCIInputImageKey)
        
        let contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter?.setValue(blurFilter?.outputImage, forKey: kCIInputImageKey)
        contrastFilter?.setValue(1.25, forKey: kCIInputContrastKey)
        contrastFilter?.setValue(3, forKey: kCIInputSaturationKey)
        
        let colorInvertFilter = CIFilter(name: "CIColorInvert")
        colorInvertFilter?.setValue(contrastFilter?.outputImage, forKey: kCIInputImageKey)
        
        
//
        // Return the final filtered image
        
    
        
        
        return contrastFilter?.outputImage ?? ciImage
    }
}

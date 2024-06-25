//
//  SampleAddVC.swift
//  ScienceScan4
//
//  Created by Neel Kondapalli on 6/18/24.
//

import Foundation
import RealmSwift
import VisionKit
import Vision
import Photos
import Speech

class SampleAddVC: UIViewController, SFSpeechRecognizerDelegate{

    @IBOutlet weak var readingField: UITextField!
    @IBOutlet weak var unitField: UITextField!
    @IBOutlet weak var sampleNameField: UITextField!
    @IBOutlet weak var noteField: UITextView!
    
    @IBOutlet weak var micButton: UIButton!
    
    var taskIndex: Int? = -1
    var sampleIndex: Int? = -1
    var sample: Sample? = nil
    
    
    var scannerAvailable: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }
    
    
    var image: UIImage?
    
    lazy var textDetectionRequest: VNRecognizeTextRequest = {
            let request = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en_GB"]
            return request
        }()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine: AVAudioEngine? = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm() // Returns Realm object reference
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        
        let results = realm.objects(Task.self)
        if let index = taskIndex {
            let task = results[index]
            let sampleArray = Array(task.sampleArray)
            if let sIndex = sampleIndex {
                if sIndex >= 0 {
                    sample = sampleArray[sIndex]
                    if let s = sample {
                        readingField.text = s.reading
                        unitField.text = s.unit
                        sampleNameField.text = s.sampleName
                        noteField.text = s.note
                    }
                    if let coun1 = readingField.text?.count, let coun2 = unitField?.text?.count, let coun3 = sampleNameField.text?.count {
                        if coun1 > 0, coun2 > 0, coun3 > 0 {
                            readingField.isUserInteractionEnabled = false
                            unitField.isUserInteractionEnabled = false
                            sampleNameField.isUserInteractionEnabled = false
                        }
                    
                    }
                }
            }
        }
        else {
            print("No index given")
        }
        
        micButton.isEnabled = false
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization{ (authStatus) in
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("Denied access to speech")
            case .restricted:
                isButtonEnabled = false
                print("Speech is restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech not authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.micButton.isEnabled = isButtonEnabled
            }
            
        }
    }
    
    func processImage() {
        guard let image = image, let cgImage = image.cgImage else { return }
                
        let requests = [textDetectionRequest]
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error {
                print("Error: \(error)")
            }
        }
    }
    
    fileprivate func handleDetectedText(request: VNRequest?, error: Error?) {
            if let error = error {
                print("Error: \(error.localizedDescription)")
                presentAlert(title: "Error", message: error.localizedDescription)
                return
            }
            guard let results = request?.results, results.count > 0 else {
                print("Error: No text was found.")
                presentAlert(title: "No reading was found", message: "Please try again or enter the reading manually")
                return
            }

            var components = [ReadingComponent]()
            
            for result in results {
                if let observation = result as? VNRecognizedTextObservation {
                    for text in observation.topCandidates(1) {
                        let component = ReadingComponent()
                        component.x = observation.boundingBox.origin.x
                        component.y = observation.boundingBox.origin.y
                        component.text = text.string
                        print("Parsed text: \(text.string)")
                        if (isValidNumber(text.string)) {
                            components.append(component)
                        }
                    }
                }
            }
            
            guard let firstComponent = components.first else { return }
            


    
            
            DispatchQueue.main.async {
               print("Reading: \(firstComponent.text)")
                self.readingField.text = firstComponent.text
                
            }
        }
    private func isValidNumber(_ text: String) -> Bool {
        let numberSet = CharacterSet(charactersIn: "0123456789")
        
        if text.rangeOfCharacter(from: numberSet.inverted) == nil {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func presentAlert(title: String, message: String) {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(controller, animated: true, completion: nil)
        }
    
    @IBAction func choosePhoto(_ sender: Any) {
        presentPhotoPicker(type: .photoLibrary)
    }
    @IBAction func takePhoto(_ sender: Any) {
        presentPhotoPicker(type: .camera)
    }
    
    fileprivate func presentPhotoPicker(type: UIImagePickerController.SourceType) {
            let controller = UIImagePickerController()
            controller.sourceType = type
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
   
    @IBAction func saveAction(_ sender: Any) {
        let mySample = Sample()
        mySample.sampleName = sampleNameField?.text ?? "No sampleName"
        mySample.reading = readingField?.text ?? "No reading"
        mySample.unit = unitField?.text ?? "No units"
        mySample.note = noteField?.text ?? "No note"
        
        if let coun1 = mySample.sampleName?.count, let coun2 = mySample.reading?.count, let coun3 = mySample.unit?.count {
            if coun1 > 0, coun2 > 0, coun3 > 0 {
                
                if let index = taskIndex {
                    let samples = results[index].sampleArray
                    do
                    {
                        
                        try realm.write {
                            if let s = sample {
                                s.sampleName = mySample.sampleName
                                s.reading = mySample.reading
                                s.unit = mySample.unit
                                s.note = mySample.note
                            } else {
                                samples.append(mySample)
                            }
                            
                        }
                        // navigationController?.popViewController(animated: true)
                        navigationController?.popViewController(animated: true)
                        
                    }
                    catch
                    {
                        print("Realm sample save error")
                    }
                    
                }
            }
           
        }
    }
    
    @IBAction func deleteSampleAction(_ sender: Any) {
        
        print("deleting")
        if let index = taskIndex {

            let task = results[index]
            let sampleArray = Array(task.sampleArray)
            if let sIndex = sampleIndex {
                if sIndex >= 0 {
                    sample = sampleArray[sIndex]
                    if let s = sample {
                        do
                        {
                            try realm.write {
                                realm.delete(s)
                            }
                            navigationController?.popViewController(animated: true)
                        }
                        catch
                        {
                            print("Realm delete sample error")
                        }
                    } else {
                        print("s bad")
                    }
                }
            } else {
                print("sIndex bad")
            }
            
        }
        else {
            print("No index given")
        }
    }
    
    
    @IBAction func startScanningPressed(_ sender: Any) {
        print("Starting scan")
        guard scannerAvailable == true else {
            print("Error: Scanner is not available. Please check settings.")
            return
        }
        
        let dataScanner = DataScannerViewController(recognizedDataTypes: [.text()],
        isHighlightingEnabled: true)
        
        dataScanner.delegate = self
        
        present(dataScanner, animated: true) {
            try? dataScanner.startScanning()
        
        
        }
        
    }
    @IBAction func startSpeechCapture() {
//        let node = audioEngine.inputNode
//        let recordingFormat = node.outputFormat(forBus: 0)
//        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {buffer, _ in
//            self.request.append(buffer)}
//        audioEngine.prepare()
//        do {
//            try audioEngine.start()
//        } catch {
//            return print(error)
//        }
//        
//        guard let myRecognizer = SFSpeechRecognizer() else {
//            return
//        }
//        if !myRecognizer.isAvailable {
//            return
//        }
//        
//        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: {result, error in
//            if let result = result {
//                let bestTranscript = result.bestTranscription.formattedString
//                self.noteField.text = bestTranscript
//            } else if let error = error {
//                print(error)
//            }})
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
        guard let inputNode = audioEngine?.inputNode else {
                fatalError("Audio engine has no input node")
            }
        
        guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
                
                var isFinal = false
                
                if result != nil {
                    
                    self.noteField.text = result?.bestTranscription.formattedString
                    isFinal = (result?.isFinal)!
                }
                
                if error != nil || isFinal {
                    self.audioEngine?.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    self.micButton.isEnabled = true
                }
            })
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine?.prepare()
            
            do {
                try audioEngine?.start()
            } catch {
                print("audioEngine couldn't start because of an error.")
            }
            
            noteField.text = "Speak into the microphone"
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            micButton.isEnabled = true
        } else {
            micButton.isEnabled = false
        }
    }
    @IBAction func micTapped(_ sender: Any) {
        if let engine = audioEngine {
            if engine.isRunning {
                audioEngine?.stop()
                recognitionRequest?.endAudio()
                micButton.isEnabled = false
                micButton.setTitle("", for: .normal)
                let microphoneImage = UIImage(systemName: "mic")
                micButton.setImage(microphoneImage, for: .normal)
            } else {
                self.startSpeechCapture()
                micButton.setTitle("End", for: .normal)
                micButton.setImage(nil, for: .normal)
            }
        }
    }
    
}


extension SampleAddVC: DataScannerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        switch item {
        case .text(let text):
            print("Text:  \(text.transcript)")
            readingField.text = text.transcript
        default:
            print("Unexpected item")
        }
        dataScanner.stopScanning()
        dataScanner.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        image = info[.originalImage] as? UIImage
        processImage()
    }
}

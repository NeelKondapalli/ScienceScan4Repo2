//
//  SampleAddVC.swift
//  ScienceScan4
//
//  Created by Neel Kondapalli on 6/18/24.
//

import Foundation
import RealmSwift

class SampleAddVC: UIViewController {

    @IBOutlet weak var readingField: UITextField!
    
    @IBOutlet weak var unitField: UITextField!
    
    @IBOutlet weak var sampleNameField: UITextField!
    
    var taskIndex: Int? = -1
    var sampleIndex: Int? = -1
    var sample: Sample? = nil
    
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
                    }
                }
            }
            
        }
        else {
            print("No index given")
        }
        
        //print(results[0].requestor)
    }
    
   
    @IBAction func saveAction(_ sender: Any) {
        let mySample = Sample()
        mySample.sampleName = sampleNameField?.text ?? "No sampleName"
        mySample.reading = readingField?.text ?? "No reading"
        mySample.unit = unitField?.text ?? "No units"
        
        if let coun = mySample.sampleName?.count {
            if coun > 0 {
                
                if let index = taskIndex {
                    let samples = results[index].sampleArray
                    do
                    {
                        
                        try realm.write {
                            if let s = sample {
                                s.sampleName = mySample.sampleName
                                s.reading = mySample.reading
                                s.unit = mySample.unit
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
    
}

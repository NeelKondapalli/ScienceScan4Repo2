//
//  ExampleLoaderVC.swift
//  ScienceScan4
//
//  Created by Neel Kondapalli on 6/19/24.
//

import Foundation
import UIKit
import RealmSwift

class ExampleLoaderVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm() // Returns Realm object reference
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
//        let myTask = Task()
//        myTask.requestor = "Neel"
//        myTask.assay = "100A"
//
//        try! realm.write {
//            realm.add(myTask)
//        }
        
        let results = realm.objects(Task.self)
        
        print("adding")
        let task1 = Task()
        if results.isEmpty {
            task1.requestor = "Neel Kondapalli"
            task1.assay = "Assay 100"
            task1.name = "Weighing Task"
            
            task1.instrumentName = "CT7 Centrifuge"
            task1.serialNumber = "12393-22"
            task1.vendor = "Thermo Scientific"
            task1.mode = "Analyze"
            task1.calibration = "June-18-2024"
            
            let sample1 = Sample()
            sample1.sampleName = "Sample A"
            sample1.reading = "10.5"
            sample1.unit = "mg/L"
            sample1.note = "I noticed some debris in the assay"
            
            let sample2 = Sample()
            sample2.sampleName = "Sample B"
            sample2.reading = "13.5"
            sample2.unit = "mg/L"
            sample2.note = "Best measurement"
            
            let sample3 = Sample()
            sample3.sampleName = "Sample C"
            sample3.reading = "4.5"
            sample3.unit = "mg/L"
            sample3.note = "Worst measurement"
            
            task1.sampleArray.append(sample1)
            task1.sampleArray.append(sample2)
            task1.sampleArray.append(sample3)
            
            
            let task2 = Task()
            task2.requestor = "Bob Smith"
            task2.assay = "Assay 11"
            task2.name = "Spin Centrifuge"
            
            task2.instrumentName = "AK-2 Centrifuge"
            task2.serialNumber = "1er3-21"
            task2.vendor = "Thermo Scientific"
            task2.mode = "Quantify"
            task2.calibration = "June-17-2024"
            
            let sample4 = Sample()
            sample4.sampleName = "Sample A"
            sample4.reading = "14.5"
            sample4.unit = "g"
            sample4.note = "Ran smoothly"
            
            let sample5 = Sample()
            sample5.sampleName = "Sample B"
            sample5.reading = "19.3"
            sample5.unit = "g"
            sample5.note = ""
            
            task2.sampleArray.append(sample4)
            task2.sampleArray.append(sample5)
            
            
            let task3 = Task()
            task3.requestor = "John Doe"
            task3.assay = "Assay 4"
            task3.name = "Quantify Proteins"
            
            task3.instrumentName = "AK-2 Protein Quantifier"
            task3.serialNumber = "8383-3"
            task3.vendor = "Thermo Scientific"
            task3.mode = "Quantify"
            task3.calibration = "June-12-2024"
            
            let sample6 = Sample()
            sample6.sampleName = "Sample A"
            sample6.reading = "1.5"
            sample6.unit = "mg/L"
            sample6.note = "Assay had a malfunction"
            
            task3.sampleArray.append(sample6)
            
            
            do
            {
                try realm.write {
                    realm.add(task1)
                    realm.add(task2)
                    realm.add(task3)
                    
                }
                
            }
            catch
            {
                print("Realm task save error")
            }
        } else {
//            let okAlert = UIAlertAction(title: "OK", style: .default) { (action) in
//                self.navigationController?.popViewController(animated: true)
//            }
//            
//            let alert = UIAlertController(title: "Cannot add examples",
//                     message: "Please delete all current tasks to generate examples.",
//                     preferredStyle: .alert)
//            alert.addAction(okAlert)
//            self.present(alert, animated: true)
            
            
        }
        
        navigationController?.popViewController(animated: true)
    }

}

//
//  TaskSetupVC.swift
//  ScienceScan4
//
//  Created by Neel Kondapalli on 6/18/24.
//

import Foundation
import RealmSwift
//
//  ViewController.swift
//  ScienceScan4
//
//  Created by Neel Kondapalli on 6/17/24.
//

import UIKit
import RealmSwift


class TaskSetupVC: UIViewController {

    @IBOutlet weak var instrumentName: UITextField!
    @IBOutlet weak var serialNumber: UITextField!
    @IBOutlet weak var calibration: UITextField!
    @IBOutlet weak var mode: UITextField!
    @IBOutlet weak var vendor: UITextField!
    
    
    @IBOutlet weak var assayLabel: UILabel!
    @IBOutlet weak var requestorLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var taskIndex: Int? = -1
    
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
        if let index = taskIndex {
            let task = realm.objects(Task.self)[index]
            
            // Pre-populate the text fields with the task values
            instrumentName.text = task.instrumentName
            serialNumber.text = task.serialNumber
            calibration.text = task.calibration
            mode.text = task.mode
            vendor.text = task.vendor
            
            nameLabel.text = task.name
            requestorLabel.text = task.requestor
            assayLabel.text = task.assay
            
            if let coun1 = instrumentName.text?.count, let coun2 = serialNumber?.text?.count, let coun3 = vendor.text?.count, let coun4 = mode.text?.count, let coun5 = calibration.text?.count {
                if coun1 > 0, coun2 > 0, coun3 > 0, coun4 > 0, coun5 > 0 {
                    instrumentName.isUserInteractionEnabled = false
                    serialNumber.isUserInteractionEnabled = false
                    vendor.isUserInteractionEnabled = false
                    mode.isUserInteractionEnabled = false
                    calibration.isUserInteractionEnabled = false
                }
            
            }
        }
        //print(results[0].requestor)
        
        
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let myTask = Task()
        myTask.instrumentName = instrumentName?.text ?? "No instrument"
        myTask.serialNumber = serialNumber?.text ?? "No s.number"
        myTask.vendor = vendor?.text ?? "No vendor"
        myTask.mode = mode?.text ?? "No mode"
        myTask.calibration = calibration?.text ?? "No calibration"
        if let coun1 = myTask.instrumentName?.count, let coun2 = myTask.serialNumber?.count, let coun3 = myTask.vendor?.count, let coun4 = myTask.mode?.count, let coun5 = myTask.calibration?.count {
            if coun1 > 0, coun2 > 0, coun3 > 0, coun4 > 0, coun5 > 0 {
                
                if let index = taskIndex {
                    let task = results[index]
                    do
                    {
                        try realm.write {
                            task.instrumentName = myTask.instrumentName
                            task.serialNumber = myTask.serialNumber
                            task.vendor = myTask.vendor
                            task.mode = myTask.mode
                            task.calibration = myTask.calibration
                            
                        }
                        // navigationController?.popViewController(animated: true)
                        
                        
                        performSegue(withIdentifier: "runTask", sender: nil)
                        
                    }
                    catch
                    {
                        print("Realm task save error")
                    }
                    
                }
            }
           
        }
        
    }
    
    @IBAction func deleteTaskAction(_ sender: Any) {
        if let index = taskIndex {
            let task = results[index]
            do
            {
                try realm.write {
                    realm.delete(task)
                    
                }
                // navigationController?.popViewController(animated: true)
               
                
            }
            catch
            {
                print("Realm delete task error")
            }
            navigationController?.popViewController(animated: true)
            
        }
        
    }
    
    @IBAction func scanCode(_ sender: Any) {
        let scanner = BarcodeScannerVC()
        
        scanner.completionHandler = { array in
            print("Array received from completion: \(array)")
            self.instrumentName.text = array[0]
            self.serialNumber.text = array[1]
            self.vendor.text = array[2]
            self.mode.text = array[3]
            self.calibration.text = array[4]
            
        }
        
        present(scanner, animated: true)
        
        
    }
        
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "runTask") {
            let indexPath = taskIndex ?? 0
            
            let taskRun = segue.destination as? TaskRunVC
            
            taskRun?.taskIndex = indexPath
            
            //tableView.deselectRow(at: indexPath, animated: true)
            
            
        }
    }
    


    

}


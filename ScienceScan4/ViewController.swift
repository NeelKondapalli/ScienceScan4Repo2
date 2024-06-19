//
//  ViewController.swift
//  ScienceScan4
//
//  Created by Neel Kondapalli on 6/17/24.
//

import UIKit
import RealmSwift

let configuration = Realm.Configuration(schemaVersion: 6)
let realm = try! Realm(configuration: configuration)
let results = realm.objects(Task.self)

class ViewController: UIViewController {
    @IBOutlet weak var requestorField: UITextField!
    
    @IBOutlet weak var assayField: UITextField!
    
    @IBOutlet weak var nameField: UITextField?
    
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
        print("count: \(results.count)")
        
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let myTask = Task()
        myTask.requestor = requestorField?.text ?? "No requestor"
        myTask.assay = assayField?.text ?? "No assay"
        myTask.name = nameField?.text ?? "No name"
        
        if let coun1 = myTask.requestor?.count, let coun2 = myTask.assay?.count, let coun3 = myTask.name?.count {
            if coun1 > 0, coun2 > 0, coun3 > 0 {
                do
                {
                    try realm.write {
                        realm.add(myTask)
                    }
                    navigationController?.popViewController(animated: true)
                }
                catch
                {
                    print("Realm task save error")
                }
            }
        }
        
        
    }
        
    
}

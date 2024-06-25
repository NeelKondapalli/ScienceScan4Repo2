//
//  ViewController.swift
//  ScienceScan4
//
//  Created by Neel Kondapalli on 6/17/24.
//

import UIKit
import RealmSwift


class TaskRunVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var taskIndex: Int? = -1
    var task: Task?
    var sampleArray: Array<Sample>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
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

            task = results[index]
            if let temp = task  {
                sampleArray = Array(temp.sampleArray)
                print("Fetched")
            }
        }
        else {
            print("No index given")
        }

        //print(results[0].requestor)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let results = realm.objects(Task.self)
        if let index = taskIndex {

            task = results[index]
            if let temp = task  {
                sampleArray = Array(temp.sampleArray)
            }
        } else {
            print("No index")
        }
        
        tableView.reloadData()
    }

    
   
    @IBAction func submitAction(_ sender: Any) {
        if let rowCount = sampleArray?.count {
            if rowCount > 0 {
                print("row: \(rowCount)")
                performSegue(withIdentifier: "submitTask", sender: nil)
            }
        }
    }
    

}

extension TaskRunVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "addSample", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addSample") {
            let indexPath = taskIndex ?? 0
            let sampleAdd = segue.destination as? SampleAddVC
            sampleAdd?.taskIndex = indexPath
            if let sampleIndex = tableView.indexPathForSelectedRow {
                sampleAdd?.sampleIndex = sampleIndex.row
            }
            
            
            
           
            
            
            //tableView.deselectRow(at: indexPath, animated: true)
            
            
        }
    }
    
    
}

extension TaskRunVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleArray?.count ?? results.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sampleCell = tableView.dequeueReusableCell(withIdentifier: "SampleCell", for: indexPath) as! SampleCell
        
        let thisSample: Sample!
        thisSample = sampleArray?[indexPath.row]

        sampleCell.sampleLabel?.text = thisSample.sampleName
        sampleCell.readingLabel?.text = thisSample.reading
        sampleCell.unitLabel?.text = thisSample.unit
//        print(task ?? "nah")
        return sampleCell
    }
    
}

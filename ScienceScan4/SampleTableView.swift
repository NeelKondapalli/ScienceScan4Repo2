//
//  SampleTableView.swift
//  ScienceScan4
//
//  Created by Neel Kondapalli on 6/18/24.
//

import Foundation
import UIKit
import RealmSwift

//let realm = try! Realm()
//let results = realm.objects(Task.self)

class SampleTableView: UITableViewController
{

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sampleCell = tableView.dequeueReusableCell(withIdentifier: "SampleCell", for: indexPath) as! SampleCell
        
        let thisTask: Task!
        thisTask = results[indexPath.row]

        sampleCell.sampleLabel?.text = thisTask.instrumentName
        sampleCell.readingLabel?.text = thisTask.mode
        print(sampleCell.readingLabel?.text ?? "nah")
        return sampleCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "setupTask", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "setupTask") {
            let indexPath = tableView.indexPathForSelectedRow!
            
            let taskSetup = segue.destination as? TaskSetupVC
            
            taskSetup?.taskIndex = indexPath.row
            
            //tableView.deselectRow(at: indexPath, animated: true)
            
            
        }
        
    }
}

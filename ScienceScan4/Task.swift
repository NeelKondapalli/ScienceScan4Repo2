//
//  Task.swift
//  ScienceScan4
//
//  Created by Neel Kondapalli on 6/18/24.
//

import Foundation
import RealmSwift

class Task: Object {
    
    @objc dynamic var requestor: String?
    @objc dynamic var assay: String?
    @objc dynamic var name: String?
    
    @objc dynamic var instrumentName: String?
    @objc dynamic var serialNumber: String?
    @objc dynamic var vendor: String?
    @objc dynamic var mode: String?
    @objc dynamic var calibration: String?
    
    let sampleArray = List<Sample>()
}

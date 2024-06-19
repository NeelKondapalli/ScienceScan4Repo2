//
//  Sample.swift
//  ScienceScan4
//
//  Created by Neel Kondapalli on 6/18/24.
//

import Foundation
import RealmSwift

class Sample: Object {
    
    @objc dynamic var sampleName: String?
    @objc dynamic var reading: String?
    @objc dynamic var unit: String?
    @objc dynamic var note: String?
}


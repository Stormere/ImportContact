//
//  User.swift
//  ImportContact
//
//  Created by steveluccy on 2019/12/8.
//  Copyright © 2019 steveluccy. All rights reserved.
//

import Foundation
import GRDB

// A plain Player struct
struct User {
    // Prefer Int64 for auto-incremented database ids
    var Id: Int64?
    var PhoneNumber: String
    var Status: Int
}
extension User: Hashable { }

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records

extension User: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    private enum Columns {
        static let Id = Column(CodingKeys.Id)
        static let PhoneNumber = Column(CodingKeys.PhoneNumber)
        static let Status = Column(CodingKeys.Status)
    }
    
  
}

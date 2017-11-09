//
//  User.swift
//  Busition
//
//  Created by neemdor semel on 05/11/2017.
//  Copyright © 2017 naknik inc. All rights reserved.
//

import UIKit

class User: NSObject {
    var email: String?
    var password: String?
    var phoneNumber: String?
    var imageURL: String?
    var UID: String?
    
    static var data = ["Email","Password","Phone Number","Profile Picture URL","UID","Type","Requests","Approved Requests","Rejected Requests"]
}

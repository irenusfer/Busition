//
//  BusinessUser.swift
//  Busition
//
//  Created by neemdor semel on 05/11/2017.
//  Copyright © 2017 naknik inc. All rights reserved.
//

import UIKit

class BusinessUser: User {
    var businessName : String?
    var address: String?
    var businessType: String?
    var workDays = [String: Bool]()

    static var days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    static var businessData = ["Business Name","Address","Business Type"]
}

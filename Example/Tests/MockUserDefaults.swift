//
//  MockUserDefaults.swift
//  UpnetixLocalizer_Tests
//
//  Created by Aleksandar Sergeev Petrov on 11.09.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import Foundation

// !!! Not used for now
class MockUserDefaults: UserDefaults {

    convenience init() {
        self.init(suiteName: "Mock User Defaults")!
    }

    override init?(suiteName suitename: String?) {
        // !!! Implicit unwrap
        UserDefaults().removePersistentDomain(forName: suitename!)
        super.init(suiteName: suitename)
    }

}

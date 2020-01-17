//
//  Extensions.swift
//  Flexx
//
//  Created by Nadezhda on 19.11.19.
//  Copyright © 2019 Upnetix. All rights reserved.
//

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

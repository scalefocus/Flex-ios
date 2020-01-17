//
//  DefaultReturnBehavior.swift
//
//  Created by Nadezhda on 8.08.19.
//  Copyright © 2019 Upnetix. All rights reserved.
//

/// Default return behavior when something went wrong while trying to get string for а key
public enum DefaultReturnBehavior {
    case empty
    case key
    case custom(String)
}

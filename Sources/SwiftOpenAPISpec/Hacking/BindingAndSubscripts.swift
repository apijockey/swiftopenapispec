//
//  File.swift
//  
//
//  Created by Patric Dubois on 02.04.24.
//

import Foundation

extension Bool {
    var flipped : Self {
        get { !self}
        set { self = !newValue}
    }
}
extension Set {
    subscript(contains el: Element) -> Bool {
        get { contains(el) }
        set {
            if newValue {
                insert(el)
            } else {
                remove(el)
            }
        }
    }
}

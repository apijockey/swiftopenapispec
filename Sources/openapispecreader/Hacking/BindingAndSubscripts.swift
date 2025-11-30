//
//  File.swift
//  
//
//  Created by Patric Dubois on 02.04.24.
//

import Foundation
import SwiftUI


/*
 Get a binding for SwiftUI
 Dynamic member lookup uses key paths
 and both subscripts and computed properties ca be part of key parths
 */
extension Binding where Value == Bool {
    func toggled() -> Self {
        Self(get: {
            !wrappedValue
        },
             set: { newValue in
            wrappedValue = !newValue}
        )
    }
}
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

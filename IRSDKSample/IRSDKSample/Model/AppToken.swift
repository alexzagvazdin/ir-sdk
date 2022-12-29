//
//  AppToken.swift
//  IRSDKSample
//
//  Created by Marcin Hatalski on 27/12/2022.
//

import Foundation

class AppToken {
    
    static func generateFake() -> String {
        UUID().uuidString
    }
}

//
//  SpotifyConstants.swift
//  Spotify Demo
//
//  Created by adam.wienconek on 23.10.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import Foundation

struct SpotifyConstants {
    static let clientID = "5eb556f84b6b4e51a4f129cc4062fd60"
//    static var tokenSwapURL = URL(string: "http://localhost:1234/swap")
//    static let tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
    static var tokenSwapURL = URL(string: "")
    static let tokenRefreshURL = URL(string: "")
    static let redirectURL = URL(string: "swiftspotify://")!
    static let sessionUserDefaultsKey = "SpotifySession"
    
    struct Notifications {
        static let sessionUpdated = Notification.Name("sessionUpdated")
    }
}

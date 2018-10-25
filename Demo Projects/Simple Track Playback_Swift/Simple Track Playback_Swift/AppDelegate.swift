//
//  AppDelegate.swift
//  Simple Track Playback_Swift
//
//  Created by adam.wienconek on 24.10.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set up shared authentication information
        let auth = SPTAuth.defaultInstance()
        
        auth.clientID = SpotifyConstants.clientID
        auth.requestedScopes = [SPTAuthStreamingScope]
        auth.redirectURL = SpotifyConstants.redirectURL
        
        if let tokenSwapURL = SpotifyConstants.tokenSwapURL {
            auth.tokenSwapURL = tokenSwapURL
        }
        if let tokenRefreshURL = SpotifyConstants.tokenRefreshURL {
            auth.tokenRefreshURL = tokenRefreshURL
        }
        
        auth.sessionUserDefaultsKey = SpotifyConstants.sessionUserDefaultsKey
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let auth = SPTAuth.defaultInstance()
        
        /// This is the callback that'll be triggered when auth is completed (or fails).
        let authCallback: SPTAuthCallback = { error, session in
            if let error = error {
                print("*** Auth error: \(error.localizedDescription)")
                return
            }
            auth.session = session
            NotificationCenter.default.post(name: SpotifyConstants.Notifications.sessionUpdated, object: nil)
        }
        
        /*
         Handle the callback from the authentication service. -[SPAuth -canHandleURL:]
         helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).
         */
        if auth.canHandle(url) {
            auth.handleAuthCallback(withTriggeredAuthURL: url, callback: authCallback)
            return true
        }
        
        return false
    }

}


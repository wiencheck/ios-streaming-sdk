//
//  ViewController.swift
//  Spotify Demo
//
//  Created by adam.wienconek on 23.10.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit
import SafariServices

class LoginViewController: UIViewController {
    
    static let playerSegueIdentifier = "player"
    private var firstLoad = true
    
    private let auth = SPTAuth.defaultInstance()
    
    weak var authViewController: UIViewController?
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var playerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSessionUpdatedNotification(_:)), name: SpotifyConstants.Notifications.sessionUpdated, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let authSession = auth.session else {
            playerButton.isEnabled = false
            statusLabel.text = "No valid session"
            return
        }
        if authSession.isValid() {
            statusLabel.text = "Successfully logged in"
            playerButton.isEnabled = true
            return
        }
        
        if auth.hasTokenRefreshService {
            renewTokenAndShowScreen()
            return
        }
        
        firstLoad = false
        
    }
    
    private func authViewController(with url: URL) -> UIViewController {
        let safariController = SFSafariViewController(url: url)
        safariController.delegate = self
        safariController.modalTransitionStyle = .coverVertical
        return safariController
    }
    
    @objc private func handleSessionUpdatedNotification(_ notification: Notification) {
        presentedViewController?.dismiss(animated: true, completion: nil)
        
        if let session = auth.session, session.isValid() {
            playerButton.isEnabled = true
            pushToNowPlayingScreen()
        } else {
            playerButton.isEnabled = false
            statusLabel.text = "Login failed"
            print("*** Failed to log in")
        }
    }
    
    private func renewTokenAndShowScreen() {
        statusLabel.text = "Refreshing token..."
        
        guard let authSession = auth.session else {
            statusLabel.text = "Refreshing token failed, no valid session available"
            return
        }
        
        auth.renewSession(authSession) { [weak self] error, session in
            self?.auth.session = session
            if let error = error {
                self?.statusLabel.text = "Refreshing token failed."
                print("*** Error renewing session: \(error.localizedDescription)")
                return
            }
            self?.pushToNowPlayingScreen()
        }
    }
    
    private func showLoginScreen() {
        statusLabel.text = "Logging in..."
        
        if SPTAuth.supportsApplicationAuthentication() {
            UIApplication.shared.open(auth.spotifyAppAuthenticationURL(), options: [:], completionHandler: nil)
        } else {
            authViewController = authViewController(with: auth.spotifyWebAuthenticationURL())
            definesPresentationContext = true
            present(authViewController!, animated: true, completion: nil)
        }
    }
    
    private func pushToNowPlayingScreen() {
        performSegue(withIdentifier: LoginViewController.playerSegueIdentifier, sender: nil)
        firstLoad = false
    }
    
    @IBAction private func loginPressed() {
        showLoginScreen()
    }
    
    @IBAction private func playerPressed() {
        pushToNowPlayingScreen()
    }
    
}

extension LoginViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("*** safariController did finish")
    }
}


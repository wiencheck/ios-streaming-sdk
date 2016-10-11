/*
 Copyright 2015 Spotify AB

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "LoginController.h"
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import "Config.h"

@interface LoginController () <SPTAuthViewDelegate, SPTStoreControllerDelegate>

@property (atomic, readwrite) SPTAuthViewController *authViewController;
@property (atomic, readwrite) BOOL firstLoad;

@end

@implementation LoginController


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedNotification:) name:@"sessionUpdated" object:nil];
    self.statusLabel.text = @"";
    self.firstLoad = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    SPTAuth *auth = [SPTAuth defaultInstance];
    // Uncomment to turn off native/SSO/flip-flop login flow
    //auth.allowNativeLogin = NO;

    // Check if we have a token at all
    if (auth.session == nil) {
        self.statusLabel.text = @"";
        return;
    }

    // Check if it's still valid
    if ([auth.session isValid] && self.firstLoad) {
        // It's still valid, show the player.
        [self showPlayer];
        return;
    }

    // Oh noes, the token has expired, if we have a token refresh service set up, we'll call tat one.
    self.statusLabel.text = @"Token expired.";
    if (auth.hasTokenRefreshService) {
        [self renewTokenAndShowPlayer];
        return;
    }

    // Else, just show login dialog
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)sessionUpdatedNotification:(NSNotification *)notification {
    self.statusLabel.text = @"";
    if(self.navigationController.topViewController == self) {
        SPTAuth *auth = [SPTAuth defaultInstance];
        if (auth.session && [auth.session isValid]) {
            [self authenticationViewController:self.authViewController didLoginWithSession:auth.session];
        } else {
            [self authenticationViewController:self.authViewController didFailToLogin:nil];
        }
    }
}

- (void)showPlayer {
    self.firstLoad = NO;
    self.statusLabel.text = @"Logged in.";
    [self performSegueWithIdentifier:@"ShowPlayer" sender:nil];
}


#pragma mark - SPTAuthViewDelegate

- (void)authenticationViewController:(SPTAuthViewController *)viewcontroller didFailToLogin:(NSError *)error {
    self.statusLabel.text = @"Login failed.";
    NSLog(@"*** Failed to log in: %@", error);
}

- (void)authenticationViewController:(SPTAuthViewController *)viewcontroller didLoginWithSession:(SPTSession *)session {
    self.statusLabel.text = @"";
    [self showPlayer];
}

- (void)authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController {
    self.statusLabel.text = @"Login cancelled.";
}


#pragma mark - SPTStoreControllerDelegate

- (void)productViewControllerDidFinish:(SPTStoreViewController *)viewController {
    self.statusLabel.text = @"App Store Dismissed.";
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)openLoginPage {
    self.statusLabel.text = @"Logging in...";

    self.authViewController = [SPTAuthViewController authenticationViewController];
    self.authViewController.delegate = self;
    self.authViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.authViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.definesPresentationContext = YES;

    [self presentViewController:self.authViewController animated:NO completion:nil];
}

- (void)renewTokenAndShowPlayer {
    self.statusLabel.text = @"Refreshing token...";
    SPTAuth *auth = [SPTAuth defaultInstance];
    // Uncomment to turn off native/SSO/flip-flop login flow
    //auth.allowNativeLogin = NO;

    [auth renewSession:auth.session callback:^(NSError *error, SPTSession *session) {
        auth.session = session;

        if (error) {
            self.statusLabel.text = @"Refreshing token failed.";
            NSLog(@"*** Error renewing session: %@", error);
            return;
        }

        [self showPlayer];
    }];
}



#pragma mark - IBActions

- (IBAction)loginClicked:(id)sender {
    [self openLoginPage];
}

- (IBAction)showSpotifyAppStoreClicked:(id)sender {
    self.statusLabel.text = @"Presenting App Store...";
    SPTStoreViewController *storeVC = [[SPTStoreViewController alloc] initWithCampaignToken:@"your_campaign_token"
                                                                              storeDelegate:self];
    [self presentViewController:storeVC animated:YES completion:nil];
}

- (IBAction)clearCookiesClicked:(id)sender {
    self.authViewController = [SPTAuthViewController authenticationViewController];
    [self.authViewController clearCookies:nil];
    self.statusLabel.text = @"Cookies cleared.";
}

@end

//
//  AppDelegate.m
//  Empty iOS SDK Project
//
//  Created by Daniel Kennett on 2014-02-19.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#import "ViewController.h"

#warning Please update these values to match the settings for your own application as these example values could change at any time.
#warning For an in-depth auth demo, see the "Basic Auth" demo project supplied with the SDK.
#warning Don't forget to add your callback URL's prefix to the URL Types section in the target's Info pane!
static NSString * const kClientId = @"e6695c6d22214e0f832006889566df9c";
static NSString * const kCallbackURL = @"spotifyiossdkexample://";

#warning If you don't provide a token swap service url the login will use implicit grant tokens, which means that your user will need to sign in again every time the token expires.
// static NSString * const kTokenSwapServiceURL = @"http://localhost:1234/swap"; // with token exchange service
static NSString * const kTokenSwapServiceURL = @""; // without

#warning If you don't provide a token refresh service url, the user will need to sign in again every time their token expires.
// static NSString * const kTokenRefreshServiceURL = @"http://localhost:1234/refresh"; // with token refresh service
static NSString * const kTokenRefreshServiceURL = @""; // without

static NSString * const kSessionUserDefaultsKey = @"SpotifySession";

@implementation AppDelegate

-(void)enableAudioPlaybackWithSession:(SPTSession *)session {
    NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:session];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:sessionData forKey:kSessionUserDefaultsKey];
    [userDefaults synchronize];
    ViewController *viewController = (ViewController *)self.window.rootViewController;
    [viewController handleNewSession:session];
}

- (void)openLoginPage {
    SPTAuth *auth = [SPTAuth defaultInstance];

    NSURL *loginURL;
    if (kTokenSwapServiceURL == nil || [kTokenSwapServiceURL isEqualToString:@""]) {
        // If we don't have a token exchange service, we need to request the token response type.
        loginURL = [auth loginURLForClientId:kClientId
                         declaredRedirectURL:[NSURL URLWithString:kCallbackURL]
                                      scopes:@[SPTAuthStreamingScope]
                            withResponseType:@"token"];
    }
    else {
        loginURL = [auth loginURLForClientId:kClientId
                         declaredRedirectURL:[NSURL URLWithString:kCallbackURL]
                                      scopes:@[SPTAuthStreamingScope]];

    }
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // If you open a URL during application:didFinishLaunchingWithOptions:, you
        // seem to get into a weird state.
        [[UIApplication sharedApplication] openURL:loginURL];
    });
}

- (void)renewTokenAndEnablePlayback {
    id sessionData = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionUserDefaultsKey];
    SPTSession *session = sessionData ? [NSKeyedUnarchiver unarchiveObjectWithData:sessionData] : nil;
    SPTAuth *auth = [SPTAuth defaultInstance];

    [auth renewSession:session withServiceEndpointAtURL:[NSURL URLWithString:kTokenRefreshServiceURL] callback:^(NSError *error, SPTSession *session) {
        if (error) {
            NSLog(@"*** Error renewing session: %@", error);
            return;
        }
        
        [self enableAudioPlaybackWithSession:session];
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    id sessionData = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionUserDefaultsKey];
    SPTSession *session = sessionData ? [NSKeyedUnarchiver unarchiveObjectWithData:sessionData] : nil;
    
    if (session) {
        // We have a session stored.
        if ([session isValid]) {
            // It's still valid, enable playback.
            [self enableAudioPlaybackWithSession:session];
        } else {
            // Oh noes, the token has expired.

            // If we're not using a backend token service we need to prompt the user to sign in again here.
            if (kTokenRefreshServiceURL == nil || [kTokenRefreshServiceURL isEqualToString:@""]) {
                [self openLoginPage];
            } else {
                [self renewTokenAndEnablePlayback];
            }
        }
    } else {
        // We don't have an session, prompt the user to sign in.
        [self openLoginPage];
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        // This is the callback that'll be triggered when auth is completed (or fails).

        if (error != nil) {
            NSLog(@"*** Auth error: %@", error);
            return;
        }

        NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:session];
        [[NSUserDefaults standardUserDefaults] setObject:sessionData
                                                  forKey:kSessionUserDefaultsKey];
        [self enableAudioPlaybackWithSession:session];
    };

    /*
     STEP 2: Handle the callback from the authentication service. -[SPAuth -canHandleURL:withDeclaredRedirectURL:]
     helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).
     */
    if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kCallbackURL]]) {
        if (kTokenSwapServiceURL == nil || [kTokenSwapServiceURL isEqualToString:@""]) {
            // If we don't have a token exchange service, we'll just handle the implicit token response directly.
            [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        } else {
            // If we have a token exchange service, we'll call it and get the token.
            [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url
                                                tokenSwapServiceEndpointAtURL:[NSURL URLWithString:kTokenSwapServiceURL]
                                                                     callback:authCallback];
        }
        return YES;
    }
    
    return NO;
}

@end

/*
 Copyright 2017 Spotify AB

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


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WebViewControllerDelegate;

@interface WebViewController : UIViewController

@property (nonatomic, weak, nullable) id <WebViewControllerDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)URL;

@end

@protocol WebViewControllerDelegate <NSObject>
@optional

/*! @abstract Delegate callback called when the user taps the Done button. Upon this call, the view controller is dismissed modally. */
- (void)webViewControllerDidFinish:(WebViewController *)controller;

/*! @abstract Invoked when the initial URL load is complete.
 @param success YES if loading completed successfully, NO if loading failed.
 @discussion This method is invoked when SFSafariViewController completes the loading of the URL that you pass
 to its initializer. It is not invoked for any subsequent page loads in the same SFSafariViewController instance.
 */
- (void)webViewController:(WebViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully;

@end

NS_ASSUME_NONNULL_END

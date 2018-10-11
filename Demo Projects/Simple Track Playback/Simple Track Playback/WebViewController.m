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

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, copy) NSURL *initialURL;

@property (nonatomic, assign) BOOL loadComplete;
@end

@implementation WebViewController

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        _initialURL = [URL copy];
    }
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURLRequest *initialRequest = [NSURLRequest requestWithURL:self.initialURL];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(didPressDone)];
    
    [self.webView loadRequest:initialRequest];
}

- (void)didPressDone
{
    if ([self.delegate respondsToSelector:@selector(webViewControllerDidFinish:)]) {
        [self.delegate webViewControllerDidFinish:self];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!self.loadComplete) {
        if ([self.delegate respondsToSelector:@selector(webViewController:didCompleteInitialLoad:)]) {
            [self.delegate webViewController:self didCompleteInitialLoad:YES];
        }
        self.loadComplete = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (!self.loadComplete) {
        if ([self.delegate respondsToSelector:@selector(webViewController:didCompleteInitialLoad:)]) {
            [self.delegate webViewController:self didCompleteInitialLoad:NO];
        }
        self.loadComplete = YES;
    }
}

@end

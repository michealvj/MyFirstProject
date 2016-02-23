//
//  PrivacyViewController.m
//  Newstracker
//
//  Created by Micheal on 23/02/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import "PrivacyViewController.h"

@interface PrivacyViewController ()

@end

@implementation PrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self navigationBarSetup];
    [self loadWebView];
}

- (void)navigationBarSetup
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = self.navigationTitle;
    [[SideBar sharedInstance] setUpImage:@"menu.png" WithTarget:self];
}

- (void)loadWebView
{
    NSString *urlAddress;
    if ([self.navigationTitle isEqualToString:@"Privacy Policy"]) {
        urlAddress = @"http://46.137.247.207/newscrewtrackeradmin/Privacy.aspx?AppView=1";
    }
    else {
        urlAddress = @"http://46.137.247.207/newscrewtrackeradmin/Terms.aspx?AppView=1";
    }
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_myWebView loadRequest:requestObj];
    _myWebView.delegate=self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_myWebView stopLoading];
}

#pragma mark - Webview Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[CodeSnip sharedInstance] showAlert:@"Network error" withMessage:[error localizedDescription] withTarget:self];
}

@end

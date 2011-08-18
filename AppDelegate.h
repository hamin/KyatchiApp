//
//  AppDelegate.h
//  KyatchiApp
//
//  Created by Haris Amin on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDelegate:NSObject<NSApplicationDelegate>{
  NSTextView *rawTextView;
  NSTextField *fromLabel;
  NSTextField *subjectLabel;
  NSTextField *dateLabel;
  NSTextField *toLabel;
  WebView *htmlWebView;
  NSTextView *plainTextView;
  WebView *htmlSourceWebView;
  NSArrayController *emails;
  NSTabViewItem *plainTextView;
}
@property (assign) IBOutlet NSTextView *rawTextView;
@property (assign) IBOutlet NSTextField *fromLabel;
@property (assign) IBOutlet NSTextField *subjectLabel;
@property (assign) IBOutlet NSTextField *dateLabel;
@property (assign) IBOutlet NSTextField *toLabel;
@property (assign) IBOutlet WebView *htmlWebView;
@property (assign) IBOutlet NSTextView *plainTextView;
@property (assign) IBOutlet WebView *htmlSourceWebView;
@property (assign) IBOutlet NSArrayController *emails;

@end

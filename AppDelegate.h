//
//  AppDelegate.h
//  KyatchiApp
//
//  Created by Haris Amin on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TMSliderControl;
@interface AppDelegate:NSObject<NSApplicationDelegate>{
  TMSliderControl *sliderControl;
}
@property (assign) IBOutlet TMSliderControl *sliderControl;

- (IBAction)sliderChanged:(id)sender;
- (IBAction)smallSliderChanged:(id)sender;

@end

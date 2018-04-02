//
//  Utilities.m
//  CLImageEditorDemo
//
//  Created by Danish on 02/04/2018.
//  Copyright © 2018 CALACULU. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

@synthesize cropRect;

+ (id)sharedUtilities {
    static Utilities *utilities = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        utilities = [[self alloc] init];
    });
    return utilities;
}

-(void)setImageAngle:(double)angle {
    if (angle == 0.5) {
        self.angle = 90.0;
    }
    else if (angle == 1.0) {
        self.angle = 180.0;
    }
    else if (angle == -0.5) {
        self.angle = 270;
    }
    else {
        self.angle = 0.0;
    }
}

@end

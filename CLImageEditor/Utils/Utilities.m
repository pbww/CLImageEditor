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
        utilities.scale = 1.0;
        utilities.angle = 0.0;
    });
    return utilities;
}

-(void)setImageAngle:(double)angle {

    float oldangle = 0.0;
    if (angle == 0.5) {
        oldangle = (self.angle + 90.0);
    }
    else if (angle == 1.0) {
         oldangle = (self.angle + 180.0);
    }
    else if (angle == -0.5) {
        oldangle = (self.angle + 270.0);
    }

    if (oldangle == 360.0) {
        self.angle = 0.0;
    }
    else if (oldangle > 360.0){
        self.angle = oldangle - 360.0;
    }
    else{
        self.angle = oldangle;
    }

//    if (angle == 0.5) {
//
//        float oldangle = (self.angle + 90.0);
//
//        if (oldangle == 360.0) {
//            self.angle = 0.0;
//        }
//        else if (oldangle > 360.0){
//            self.angle = oldangle - 360.0;
//        }
//
//
//        self.angle = 90.0;
//    }
//    else if (angle == 1.0) {
//        self.angle = 180.0;
//    }
//    else if (angle == -0.5) {
//        self.angle = 270;
//    }
//    else {
//        self.angle = 0.0;
//    }
}

-(double)getImageAngle:(double)angle {
    if (angle == 90.0) {
        return 0.5;
    }
    else if (angle == 180.0) {
        return 1.0;
    }
    else if (angle == 270.0 || angle == -90.0) {
        return -0.5;
    }

    return 0.0;
}

-(CATransform3D)getTransfromImage
{
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, (self.angle * M_PI / 180), 0, 0, 1);
    transform = CATransform3DScale(transform, self.scale, self.scale, 1);
    return transform;
}

@end

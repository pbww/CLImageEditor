//
//  Utilities.m
//  CLImageEditorDemo
//
//  Created by Danish on 02/04/2018.
//  Copyright © 2018 CALACULU. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

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

@end

//
//  Utilities.h
//  CLImageEditorDemo
//
//  Created by Danish on 02/04/2018.
//  Copyright © 2018 CALACULU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) double angle;
@property (nonatomic, assign) BOOL isCrop;
@property (nonatomic, assign) BOOL isRotate;

+ (id)sharedUtilities;

-(void)setImageAngle:(double)angle;
@end

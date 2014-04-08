//
//  CCImageManager.h
//  CachingClient
//
//  Created by Robert Guo on 3/11/14.
//  Copyright (c) 2014 Robert Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCImageManager : NSObject

+(CCImageManager *)sharedInstance;
-(void)addImageRecord:(NSDictionary *)imageInfo;
-(void)removeImageRecord:(NSDictionary *)imageInfo;
-(NSArray *)getAllThumbs;
-(NSArray *)getAllImageNames;
-(NSArray *)getCachedImageNames;
@end

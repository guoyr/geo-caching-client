//
//  CCImageManager.h
//  CachingClient
//
//  Created by Robert Guo on 3/11/14.
//  Copyright (c) 2014 Robert Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOCAL_CACHE_SIZE 2
#define IMAGE_THUMBS_KEY @"imageThumb"
#define IMAGE_FULL_KEY @"imageFull"

#define IMAGE_UID_KEY @"image_uid_key"
#define DEVICE_UID_KEY @"device_uid_key"

@interface CCImageManager : NSObject

+(CCImageManager *)sharedInstance;
-(void)addImageRecord:(NSDictionary *)imageInfo;
-(void)removeImageRecord:(NSDictionary *)imageInfo;
-(NSArray *)getAllThumbs;
-(NSArray *)getAllImageNames;
-(NSArray *)getCachedImageNames;
@end

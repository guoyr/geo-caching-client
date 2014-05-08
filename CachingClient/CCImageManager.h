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
#define USER_ID_KEY @"user_id"

#define CLIENT_LOCATION_KEY @"client_location"
#define SERVER_LOCATION_KEY @"server_location"

typedef enum ServerLocation: NSInteger {
    AUTOMATIC_SERVER = 0,
    WEST_SERVER,
    EAST_SERVER,
    LOCALHOST_SERVER
} ServerLocation;

typedef enum ClientLocation: NSInteger {
    CENTRAL_CLIENT = 0,
    EAST_CLIENT,
    WEST_CLIENT,
    ANTARCTICA_CLIENT,
    NONE_CLIENT
} ClientLocation;

@interface CCImageManager : NSObject

+(CCImageManager *)sharedInstance;
-(void)addImageRecord:(NSDictionary *)imageInfo;
-(void)removeImageRecord:(NSDictionary *)imageInfo;
-(NSArray *)getAllThumbs;
-(NSArray *)getAllImageNames;
-(NSArray *)getCachedImageNames;

@property (nonatomic, strong) NSMutableArray *imageThumbsInfoArray;
@property (nonatomic, strong) NSMutableArray *cachedImageInfoArray;

@end

//
//  CCImageManager.h
//  CachingClient
//
//  Created by Robert Guo on 3/11/14.
//  Copyright (c) 2014 Robert Guo. All rights reserved.
//
@class SDImageCache;

#import <Foundation/Foundation.h>

#define LOCAL_CACHE_SIZE 2
#define IMAGE_THUMBS_KEY @"imageThumb"
#define IMAGE_FULL_KEY @"imageFull"

#define IMAGE_UID_KEY @"image_uid_key"
#define DEVICE_UID_KEY @"device_uid_key"
#define USER_ID_KEY @"user_uid_key"

#define SERVER_LOCATION_KEY @"server_location"

#define CLIENT_LATENCY_KEY @"latency_key"

#define TRANSFER_FROM_KEY @"from_key"
#define TRANSER_TO_KEY @"to_key"

#define CACHE_LIFE_KEY @"cache_life"
#define CACHE_SIZE_KEY @"cache_size"

#define THUMBS_CACHE_KEY @"thumbs_cache"
#define FULL_IMG_CACHE_KEY @"full_image_cache"

#define SERVER_DOWNLOAD_ADDR @"west-5412.cloudapp.net/image/"


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
-(NSArray *)getAllThumbs;
-(NSArray *)getAllImageNames;
-(NSArray *)getCachedImageNames;
-(void)save;
-(void)removeAllImages;
-(void)removeLRUimageIfNeeded;
-(void)addFetchedImageToCache:(UIImage *)image name:(NSString *)name;
-(void)addImageReadRecord:(NSString *)imageName;
-(NSArray *)getClientLocation;

@property (nonatomic, strong) NSMutableArray *imageThumbsInfoArray;
@property (nonatomic, strong) NSMutableArray *cachedImageInfoArray;
@property (nonatomic, strong) SDImageCache *imageCache;




@end

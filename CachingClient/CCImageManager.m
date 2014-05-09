//
//  CCImageManager.m
//  CachingClient
//
//  Created by Robert Guo on 3/11/14.
//  Copyright (c) 2014 Robert Guo. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <AFNetworking/AFNetworking.h>
#import <SDImageCache.h>
#import "CCImageManager.h"
#import "UIImage+ScalingMethods.h"
#import "CCMenuViewController.h"

#define SERVER_UPLOAD_ADDR @"http://west-5412.cloudapp.net:8666/image/"
//#define SERVER_UPLOAD_ADDR @"http://localhost:8666/image/"


@interface CCImageManager()

@end

@implementation CCImageManager

-(SDImageCache *)imageCache
{
    if (!_imageCache) {
        _imageCache = [SDImageCache sharedImageCache];
    }
    return _imageCache;
}

-(NSMutableArray *)imageThumbsInfoArray
{
    if (!_imageThumbsInfoArray) {
        _imageThumbsInfoArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_THUMBS_KEY]];
    }
    return _imageThumbsInfoArray;
}

-(NSMutableArray *)cachedImageInfoArray
{
    if (!_cachedImageInfoArray) {
        _cachedImageInfoArray = [[NSMutableArray alloc] init];
    }
    
    return _cachedImageInfoArray;
}

-(void)saveImageThumb:(UIImage *)newImage named:(NSString *)name
{
    [[SDImageCache sharedImageCache] storeImage:newImage forKey:[name stringByAppendingString:@"_thumb"]];
    
    NSData *imageData = UIImagePNGRepresentation(newImage);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",name]];
    if (![imageData writeToFile:imagePath atomically:NO]) {
        NSLog((@"Failed to cache image data to disk"));
    }
}

-(void)removeAllImages
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        BOOL success = [fm removeItemAtPath:[directory stringByAppendingPathComponent:file] error:&error];
        if (!success || error) {
            // it failed.
        }
    }
}

-(UIImage *)getImageThumbNamed:(NSString *)name
{
    UIImage *img;
    if (!(img = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[name stringByAppendingString:@"_thumb"]])) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *directory = [paths objectAtIndex:0];
        NSString *imageName = [NSString stringWithFormat:@"%@.png",name];
        
        img = [UIImage imageWithContentsOfFile:[directory stringByAppendingPathComponent:imageName]];
        img = [UIImage imageWithImage:img scaledToFillSize:CGSizeMake(IMAGE_CELL_SIZE, IMAGE_CELL_SIZE)];
        
        [[SDImageCache sharedImageCache] storeImage:img forKey:[name stringByAppendingString:@"_thumb"]];
    }
    
    return img ;
}

-(void)save
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject:self.imageThumbsInfoArray forKey:IMAGE_THUMBS_KEY];
    
}

+ (id)sharedInstance {
    static CCImageManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(NSArray *)getAllThumbs
{
    NSMutableArray *imgArray = [[NSMutableArray alloc] initWithCapacity:[self.imageThumbsInfoArray count]];
    for (NSString *imgName in self.imageThumbsInfoArray) {

        [imgArray addObject:[self getImageThumbNamed:imgName]];
    }
    return [NSArray arrayWithArray:imgArray];
}

-(NSArray *)getAllImageNames
{
    return [NSArray arrayWithArray:self.imageThumbsInfoArray];
}

-(NSArray *)getCachedImageNames
{
    return [NSArray arrayWithArray:self.cachedImageInfoArray];
}

-(NSString *)getPhotoUID:(UIImage *)image
{
    NSData* data = UIImagePNGRepresentation(image);
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    
    const void* src = [data bytes];
    unsigned int len = (int)[data length];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(src, len, result);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", result[i]];
    
    return output;
}

// called when an image is prefetched
-(void)addToCacheImage:(UIImage *)image Name:(NSString *)name
{
    if (![self.cachedImageInfoArray containsObject:name]) {
        //TODO: logic to update the local cache
        
        [self.imageCache storeImage:image forKey:name];
        [self.cachedImageInfoArray addObject:name];
        
    }
}

// called when a new image is added by the client
// takes care of adding _thumb to the image name
-(void)addToThumbsCacheImage:(UIImage *)image Name:(NSString *)name
{
    
    [self.imageThumbsInfoArray addObject:name];
    image = [UIImage imageWithImage:image scaledToFillSize:CGSizeMake(IMAGE_CELL_SIZE, IMAGE_CELL_SIZE)];
    [self saveImageThumb:image named:name];

    NSLog(@"image thumbs list length: %lu",(unsigned long)[self.imageThumbsInfoArray count]);

}

-(BOOL)imageExists:(NSString *)imageName
{
    return [self.imageThumbsInfoArray containsObject:imageName];
}

-(void)addImageRecord:(NSDictionary *)imageInfo
{
    UIImage *image = imageInfo[UIImagePickerControllerOriginalImage];
    NSString *uid = [self getPhotoUID:image];
    
    if ([self imageExists:uid]) {
        NSLog(@"image already exists, not added");
        return;
    }
    
    NSLog(@"adding image");
    
    [self removeLRUimageIfNeeded];
    
    [self addToThumbsCacheImage:image Name:uid];
    [self addToCacheImage:image Name:uid];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSUUID *deviceID = [[UIDevice currentDevice] identifierForVendor];
    
    
    //TODO: add closest server

    NSArray *info = [self getClientLocation];
    NSString *eLatency = [(NSNumber *)info[0] stringValue];
    NSString *wLatency = [(NSNumber *)info[1] stringValue];
    NSString *serverAddr = info[2];
    
    NSDictionary *parameters = @{IMAGE_UID_KEY: uid,USER_ID_KEY:[deviceID UUIDString],CLIENT_LATENCY_EAST_KEY:eLatency, CLIENT_LATENCY_WEST_KEY: wLatency};

    NSLog(@"http://west-5412.cloudapp.net:8666/image/?image_uid_key=%@&user_id=%@&is_client=1", uid, [deviceID UUIDString]);

    [manager POST:serverAddr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:imageData name:uid];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)removeLRUimageIfNeeded
{
    NSInteger cacheSize = [[NSUserDefaults standardUserDefaults] integerForKey:CACHE_SIZE_KEY];
    if (self.cachedImageInfoArray.count >= cacheSize) {
        NSString *imgName = self.cachedImageInfoArray[0];
        [self.cachedImageInfoArray removeObjectAtIndex:0];
        [self.imageCache removeImageForKey:imgName];
    }
}

-(void)addFetchedImageToCache:(UIImage *)image name:(NSString *)name
{
    [self removeLRUimageIfNeeded]; // caching logic
    [self.imageCache storeImage:image forKey:name];
    [self.cachedImageInfoArray addObject:name];
    
}

-(void)addImageReadRecord:(NSString *)imageName
{
    // move this image to last index
    [self.cachedImageInfoArray removeObject:imageName];
    [self.cachedImageInfoArray addObject:imageName];
}

-(NSArray *)getClientLocation
{
    NSInteger locationIndex = [[NSUserDefaults standardUserDefaults] integerForKey:SERVER_LOCATION_KEY];
    NSString *location;
    float latency_west;
    float latency_east;
    
    int precision = 10000;
    float rand1 = (arc4random() % precision) / (float)precision;
    float rand2 = (arc4random() % precision) / (float)precision;
    
    NSString *eastLoc = @"http://east-5412.cloudapp.net:8666/image/";
    NSString *westLoc = @"http://west-5412.cloudapp.net:8666/image/";
    
    switch (locationIndex) {
        case CENTRAL_CLIENT:
            latency_west = rand1 * 100 + 50;
            latency_east = rand2 * 100 + 50;
            break;
        case EAST_CLIENT:
            latency_east = rand1 * 20 + 20;
            latency_west = latency_east + rand2 * 100 + 100;
            break;
        case WEST_CLIENT:
            latency_west = rand1 * 20 + 20;
            latency_east = latency_east + rand2 * 100 + 100;
            break;
        case ANTARCTICA_CLIENT:
            latency_west = rand1 * 1000 + 1000;
            latency_east = rand2 * 1000 + 1000;
            break;
        case NONE_CLIENT:
            location = @"http://localhost:8666/image/";
            latency_east = 0;
            latency_west = 0;
            break;
        default:
            break;
    }
    if (!location) {
        location = latency_east < latency_west ? eastLoc : westLoc;
    }
    
    return @[[NSNumber numberWithFloat:latency_east], [NSNumber numberWithFloat:latency_west], location];
}

@end

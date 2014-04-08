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

#define SERVER_UPLOAD_ADDR @"west-5412.cloudapp.net/upload/"
#define SERVER_REMOVE_ADDR @"west-5412.cloudapp.net/remove/"

#define LOCAL_CACHE_SIZE 2

@interface CCImageManager()

@property (nonatomic, strong) NSMutableArray *imageThumbsInfoArray;
@property (nonatomic, strong) NSMutableArray *cachedImageInfoArray;

@end

@implementation CCImageManager

-(NSMutableArray *)imageThumbsInfoArray
{
    if (!_imageThumbsInfoArray) {
        _imageThumbsInfoArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"imageList"]];
    }
    return _imageThumbsInfoArray;
}

-(NSMutableArray *)cachedImageInfoArray
{
    if (!_cachedImageInfoArray) {
        _cachedImageInfoArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"cachedImageList"]];
    }
    
    return _cachedImageInfoArray;
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
    NSMutableArray *imgArray = [[NSMutableArray alloc] initWithCapacity:[_imageThumbsInfoArray count]];
    for (NSString *imgName in _imageThumbsInfoArray) {
        NSString *thumbName = [imgName stringByAppendingString:@"_thumb"];
        [imgArray addObject:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:thumbName]];
    }
    return [NSArray arrayWithArray:imgArray];
}

-(NSArray *)getAllImageNames
{
    return [NSArray arrayWithArray:_imageThumbsInfoArray];
}

-(NSArray *)getCachedImageNames
{
    return [NSArray arrayWithArray:_cachedImageInfoArray];
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
    if (![_cachedImageInfoArray containsObject:name]) {
        //TODO: logic to update the local cache
        
        [[SDImageCache sharedImageCache] storeImage:image forKey:name toDisk:YES];
        [self.cachedImageInfoArray addObject:name];
    }
}

// called when a new image is added by the client
// takes care of adding _thumb to the image name
-(void)addToThumbsCacheImage:(UIImage *)image Name:(NSString *)name
{
    
    if (![_imageThumbsInfoArray containsObject:name]) {
        [self.imageThumbsInfoArray addObject:name];
        image = [UIImage imageWithImage:image scaledToFillSize:CGSizeMake(IMAGE_CELL_SIZE, IMAGE_CELL_SIZE)];
        name = [name stringByAppendingString:@"_thumb"];
        [[SDImageCache sharedImageCache] storeImage:image forKey:name];
        NSLog(@"added image to thumbs");
    }
    NSLog(@"%lu",(unsigned long)[self.imageThumbsInfoArray count]);

}

-(void)addImageRecord:(NSDictionary *)imageInfo
{
    NSLog(@"in add image record");
    UIImage *image = imageInfo[UIImagePickerControllerOriginalImage];
    NSURL *imageURL = imageInfo[UIImagePickerControllerReferenceURL];
    NSString *uid = [self getPhotoUID:image];
    [self addToThumbsCacheImage:image Name:uid];
    [self addToCacheImage:image Name:uid];
    // add image to local cache when viewed, not when uploaded.
    
        
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:SERVER_UPLOAD_ADDR];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:imageURL progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
        }
    }];
//        [uploadTask resume];
}

// called when removing an image from the client
-(void)removeImageRecord:(NSDictionary *)imageInfo
{
    UIImage *image = imageInfo[UIImagePickerControllerOriginalImage];
    NSString *uid = [self getPhotoUID:image];
    NSString *thumbsUID = [uid stringByAppendingString:@"_thumb"];
    [_imageThumbsInfoArray removeObject:uid];
    [[SDImageCache sharedImageCache] removeImageForKey:thumbsUID fromDisk:YES];
    if ([_cachedImageInfoArray containsObject:uid]) {
        [_cachedImageInfoArray removeObject:uid];
        [[SDImageCache sharedImageCache] removeImageForKey:uid fromDisk:YES];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"foo": @"bar"};
//    [manager POST:SERVER_REMOVE_ADDR parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
}

@end

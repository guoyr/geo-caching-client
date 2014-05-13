//
//  CCPhotoDetailViewController.m
//  CachingClient
//
//  Created by Robert Guo on 3/7/14.
//  Copyright (c) 2014 Robert Guo. All rights reserved.
//

#import "CCPhotoDetailViewController.h"
#import "CCImageManager.h"
#import <SDImageCache.h>
#import <AFNetworking/AFNetworking.h>

@interface CCPhotoDetailViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic, strong) UILabel *transferTimeLabel;

@end


@implementation CCPhotoDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"View Image detail";
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapGR];
    CGRect frame = self.view.bounds;
    frame.size.height = 440;
    self.imageView = [[UIImageView alloc] initWithFrame:frame];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.imageView];
    [self.imageView setBackgroundColor:[UIColor blackColor]];
    
    self.transferTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 440, 320, 48)];
    [self.transferTimeLabel setBackgroundColor:[UIColor darkGrayColor]];
    [self.transferTimeLabel setTextColor:[UIColor whiteColor]];
    self.transferTimeLabel.text = @"";
    [self.transferTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.transferTimeLabel];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageNames = [[CCImageManager sharedInstance] getAllImageNames];
    self.imageView.image = nil;
    self.transferTimeLabel.text = nil;
}

-(void)prefetchImageAtIndex:(NSInteger)index
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"prefetchImage"]) {
        NSLog(@"prefetching image at index %ld", index);
        [self getImageAndShow:NO atIndex:index];
    } else {
        NSLog(@"no prefetch");
    }
}


-(void)getImageAndShow:(BOOL)show atIndex:(NSInteger)index
{

    index %= self.imageNames.count;
    if (show) {
        [self prefetchImageAtIndex:self.curIndex + 1];
    }
    NSString *imageName = self.imageNames[index];
    NSLog(@"showing image %@", imageName);

    CCImageManager *m = [CCImageManager sharedInstance];
    if ([m.cachedImageInfoArray containsObject:imageName] && show) {
        self.transferTimeLabel.text = @"Image Exists Locally";
        [m addImageReadRecord:imageName];
        UIImage *image = [m.imageCache imageFromMemoryCacheForKey:imageName];
        
        [self.imageView setImage:image];

        
    } else {
        NSLog(@"image doesn't exist locally");
        // doesn't exist locally, have to get it from server;
        NSUUID *deviceID = [[UIDevice currentDevice] identifierForVendor];

        NSArray *info = [m getClientLocation];
        NSString *latency = [(NSNumber *)info[0] stringValue];
        NSString *serverAddr = info[1];
        
        NSDictionary *params = @{IMAGE_UID_KEY:imageName, USER_ID_KEY:[deviceID UUIDString], CLIENT_LATENCY_KEY:latency,  @"is_client":@"1"};
        NSLog(@"POST: server: %@ parameters:%@", serverAddr, params);
        NSDate *start = [NSDate date];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFImageResponseSerializer serializer];
        [manager GET:serverAddr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (show) {
                NSString *time = [NSString stringWithFormat:@"Downloading from \"%@\" done in :%.2fs", [serverAddr substringWithRange:NSMakeRange(7, 4)],[[NSDate date] timeIntervalSinceDate:start]];
                self.transferTimeLabel.text = time;
                _imageView.image = responseObject;
            }
            [m addFetchedImageToCache:responseObject name:imageName];
            NSLog(@"Success: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Get Image Failed" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [view show];
        }];
    }
}

-(void)viewTapped:(UITapGestureRecognizer *)sender
{
    NSInteger index = self.curIndex;
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:self.view];
        if (location.x < self.view.bounds.size.width / 2) {
            // tapped on the left
            if (index > 0) {
                index--;
            }
        } else {
            //tapped on the right
            if (index < self.imageNames.count - 1) {
                index++;
            }
        }
        if (index != _curIndex) {
            self.curIndex = index;
            [self getImageAndShow:YES atIndex:self.curIndex];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getImageAndShow:YES atIndex:self.curIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
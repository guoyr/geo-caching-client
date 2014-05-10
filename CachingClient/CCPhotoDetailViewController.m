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
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    [self.imageView setBackgroundColor:[UIColor blackColor]];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageNames = [[CCImageManager sharedInstance] getAllImageNames];
    
}


-(void)showImage
{
    NSString *imageName = self.imageNames[self.curIndex];
    NSLog(@"showing image %@", imageName);

    CCImageManager *m = [CCImageManager sharedInstance];
    if ([m.cachedImageInfoArray containsObject:imageName]) {
        NSLog(@"image exists locally");
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

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFImageResponseSerializer serializer];
        [manager GET:serverAddr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            _imageView.image = responseObject;
            [m addFetchedImageToCache:responseObject name:imageName];
            NSLog(@"Success: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

-(void)viewTapped:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:self.view];
        if (location.x < self.view.bounds.size.width / 2) {
            // tapped on the left
            if (_curIndex > 0) {
                _curIndex--;
            }
        } else {
            //tapped on the right
            if (_curIndex < self.imageNames.count - 1) {
                _curIndex++;
            }
        }
        [self showImage];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showImage];
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
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

#define SERVER_DOWNLOAD_ADDR @"west-5412.cloudapp.net/download/"

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
    [self.view addSubview:self.imageView];
    [self.imageView setBackgroundColor:[UIColor blueColor]];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageNames = [[CCImageManager sharedInstance] getCachedImageNames];
    
}

-(void)showImage:(NSString *)imageName
{
    if ([_imageNames containsObject:imageName]) {
        [self.imageView setImage:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageName]];
    } else {
        // doesn't exist locally, have to get it from server;
        NSURL *URL = [NSURL URLWithString:SERVER_DOWNLOAD_ADDR];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Response: %@", responseObject);
            _imageView.image = responseObject;
            //TODO: put caching logic here
            [[SDImageCache sharedImageCache] storeImage:responseObject forKey:imageName];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Image error: %@", error);
        }];
        [requestOperation start];
    }
}

-(void)viewTapped:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:self.view];
        if (location.x < self.view.bounds.size.width / 2) {
            // tapped on the left
            _curIndex--;
        } else {
            //tapped on the right
            _curIndex++;
        }
        [self showImage:_imageNames[_curIndex]];
    }
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
//
//  CCMenuViewController.m
//  CachingClient
//
//  Created by Robert Guo on 3/7/14.
//  Copyright (c) 2014 Robert Guo. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking.h>
#import "UIImage+ScalingMethods.h"
#import "CCMenuViewController.h"
#import "CCPhotosViewController.h"
#import "CCImageManager.h"
#import "CCSettingsTableViewController.h"

@interface CCMenuViewController ()

@property (nonatomic, strong) UIButton *uploadButton;
@property (nonatomic, strong) UIButton *viewButton;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *overlayView;
@property (nonatomic, strong) NSDate *startDate;
@end

@implementation CCMenuViewController

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
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Geo-caching Client"];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [self.navigationController.navigationBar setTintColor:[UIColor lightGrayColor]];
    self.navigationController.navigationBar.translucent = NO;
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.uploadButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 70, 200, 150)];
    [self.uploadButton.layer setCornerRadius:5.0];
    [self.uploadButton setTitle:@"Upload Photos" forState:UIControlStateNormal];
    [self.uploadButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.uploadButton addTarget:self action:@selector(uploadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.uploadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.uploadButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    
    self.viewButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 290, 200, 150)];
    [self.viewButton.layer setCornerRadius:5.0];
    [self.viewButton setTitle:@"View Photos" forState:UIControlStateNormal];
    [self.viewButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.viewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.viewButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];

    [self.viewButton addTarget:self action:@selector(viewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    self.resetButton = [[UIButton alloc] initWithFrame:CGRectMake(240, 458, 80, 40)];
    [self.resetButton setBackgroundColor:[UIColor darkGrayColor]];
    [self.resetButton setTitle:@"Settings" forState:UIControlStateNormal];
    [self.resetButton addTarget:self action:@selector(reset:) forControlEvents:UIControlEventTouchUpInside];
    [self.resetButton.layer setCornerRadius:5.0];
    self.picker = [[UIImagePickerController alloc] init];
    [self.picker.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [self.picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self.picker.navigationBar setTintColor:[UIColor lightGrayColor]];
    [self.picker setDelegate:self];
    
    self.overlayView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 240, 160)];
    CGPoint center = self.view.center;
    center.y -= 40;
    self.overlayView.center = center;
    self.overlayView.layer.cornerRadius = 5;
    self.overlayView.backgroundColor = [UIColor lightGrayColor];
    [self.overlayView setAlpha:0.8];
    [self.overlayView setTitle:@"Uploading Image" forState:UIControlStateNormal];
    self.overlayView.titleLabel.textColor = [UIColor blackColor];
    
    [self.overlayView addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.uploadButton];
    [self.view addSubview:self.viewButton];
    [self.view addSubview:self.resetButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadCompleted:) name:@"UploadCompleteNotification" object:nil];

}

-(void)done:(id)sender
{
    [self.overlayView removeFromSuperview];
    self.uploadButton.hidden = NO;
    self.viewButton.hidden = NO;
}

-(void)uploadCompleted:(NSNotification *)notification
{
    NSLog(@"upload completed");
    NSString *sent = (NSString *)notification.object;
    
    if ([sent isEqualToString:@"True"]) {
        NSDate *doneDate = [NSDate date];
        [self.overlayView setTitle:[NSString stringWithFormat:@"Uploading done in :%.2fs", [doneDate timeIntervalSinceDate:self.startDate]] forState:UIControlStateNormal];
    } else {
        [self.overlayView setTitle:@"Already Uploaded" forState:UIControlStateNormal];
    }
    
    self.overlayView.titleLabel.textColor = [UIColor blackColor];

    [self.overlayView setUserInteractionEnabled:YES];
}

-(void)reset:(id)sender
{
    UIStoryboard *tableViewStoryboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    CCSettingsTableViewController *vc = [tableViewStoryboard instantiateViewControllerWithIdentifier:@"settingsVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)uploadButtonPressed:(id)sender
{
    [self presentViewController:self.picker animated:YES completion:^{
    }];
}

-(void)viewButtonPressed:(id)sender
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(IMAGE_CELL_SIZE, IMAGE_CELL_SIZE)];
    [layout setSectionInset:UIEdgeInsetsMake(3, 3, 3, 3)];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setMinimumInteritemSpacing:3.f];
    [layout setMinimumLineSpacing:3.f];
    
    CCPhotosViewController *viewer = [[CCPhotosViewController alloc] initWithCollectionViewLayout:layout];

    [viewer setImageNames:[[CCImageManager sharedInstance] getAllImageNames]];
    [viewer setThumbs:[[CCImageManager sharedInstance] getAllThumbs]];
    [self.navigationController pushViewController:viewer animated:YES];
}

#pragma mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.view addSubview:self.overlayView];
        [self.overlayView setUserInteractionEnabled:NO];
        self.uploadButton.hidden = YES;
        self.viewButton.hidden = YES;
        [self.overlayView setTitle:@"Uploading Image" forState:UIControlStateNormal];
        self.overlayView.titleLabel.textColor = [UIColor blackColor];
        [[CCImageManager sharedInstance] addImageRecord:info];
        self.startDate = [NSDate date];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
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

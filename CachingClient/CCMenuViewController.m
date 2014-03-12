//
//  CCMenuViewController.m
//  CachingClient
//
//  Created by Robert Guo on 3/7/14.
//  Copyright (c) 2014 Robert Guo. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+ScalingMethods.h"
#import "CCMenuViewController.h"
#import "CCPhotosViewController.h"
#import "CCImageManager.h"


@interface CCMenuViewController ()

@property (nonatomic, strong) UIButton *uploadButton;
@property (nonatomic, strong) UIButton *viewButton;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) CCPhotosViewController *viewer;

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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self.navigationController.navigationBar setTintColor:[UIColor lightGrayColor]];
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


    self.picker = [[UIImagePickerController alloc] init];
    [self.picker.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [self.picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self.picker.navigationBar setTintColor:[UIColor lightGrayColor]];
    [self.picker setDelegate:self];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(IMAGE_CELL_SIZE, IMAGE_CELL_SIZE)];
    [layout setSectionInset:UIEdgeInsetsMake(3, 3, 3, 3)];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setMinimumInteritemSpacing:3.f];
    [layout setMinimumLineSpacing:3.f];
    
    self.viewer = [[CCPhotosViewController alloc] initWithCollectionViewLayout:layout];
    
    [self.view addSubview:self.uploadButton];
    [self.view addSubview:self.viewButton];
}

-(void)uploadButtonPressed:(id)sender
{
    [self presentViewController:self.picker animated:YES completion:^{

    }];
}

-(void)viewButtonPressed:(id)sender
{
    [self.viewer setImageNames:[[CCImageManager sharedInstance] getAllImageNames]];
    [self.viewer setThumbs:[[CCImageManager sharedInstance] getAllThumbs]];
    [self.navigationController pushViewController:self.viewer animated:YES];
}

#pragma mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[CCImageManager sharedInstance] addImageRecord:info];
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

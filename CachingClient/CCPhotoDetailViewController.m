//
//  CCPhotoDetailViewController.m
//  CachingClient
//
//  Created by Robert Guo on 3/7/14.
//  Copyright (c) 2014 Robert Guo. All rights reserved.
//

#import "CCPhotoDetailViewController.h"

@interface CCPhotoDetailViewController ()

@property (nonatomic, strong) UIImageView *imageView;

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
    [self.view addSubview:self.imageView];
    [self.imageView setBackgroundColor:[UIColor blueColor]];
    // Do any additional setup after loading the view.
}

-(void)viewTapped:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:self.view];
        if (location.x < self.view.bounds.size.width / 2) {
            // tapped on the left
            NSLog(@"tapped on left");
        } else {
            //tapped on the right
            NSLog(@"tapped on right");
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setImageNamed:(NSString *)name
{
    
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
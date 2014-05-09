//
//  CCPhotosViewController.m
//  CachingClient
//
//  Created by Robert Guo on 3/7/14.
//  Copyright (c) 2014 Robert Guo. All rights reserved.
//

#import <SDWebImage/SDImageCache.h>
#import "CCPhotosViewController.h"
#import "CCPhotoCell.h"
#import "CCPhotoDetailViewController.h"

@interface CCPhotosViewController ()

@property (nonatomic, strong) CCPhotoDetailViewController *detailVC;

@end

@implementation CCPhotosViewController

-(id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.title = @"View Photos";
    }
    return self;
}

-(void)setThumbs:(NSArray *)thumbs
{
    _thumbs = thumbs;
    [self.collectionView reloadData];
}

-(CCPhotoDetailViewController *)detailVC
{
    if (!_detailVC) {
        _detailVC = [[CCPhotoDetailViewController alloc] init];
    }
    
    return _detailVC;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.collectionViewLayout];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView registerClass:[CCPhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[SDImageCache sharedImageCache] cleanDisk];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_thumbs count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    [cell addImage:[_thumbs objectAtIndex:indexPath.item]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.detailVC setCurIndex:(int)indexPath.item];
    [self.navigationController pushViewController:self.detailVC animated:YES];
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

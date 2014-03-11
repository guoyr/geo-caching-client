//
//  CCPhotoCell.m
//  CachingClient
//
//  Created by Robert Guo on 3/7/14.
//  Copyright (c) 2014 Robert Guo. All rights reserved.
//

#import "CCPhotoCell.h"

@interface CCPhotoCell()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CCPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)addImage:(UIImage *)image
{
    if (self.imageView.superview) {
        [self.imageView removeFromSuperview];
    }
    self.imageView = [[UIImageView alloc] initWithImage:image];
    [self.contentView addSubview:self.imageView];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

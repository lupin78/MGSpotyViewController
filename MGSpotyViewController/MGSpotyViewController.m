//
//  MGSpotyViewController.m
//  MGSpotyView
//
//  Created by Matteo Gobbi on 25/06/2014.
//  Copyright (c) 2014 Matteo Gobbi. All rights reserved.
//

#import "MGSpotyViewController.h"
#import "UIImageView+LBBlurredImage.h"

CGFloat const kMGOffsetEffects = 40.0;

@implementation MGSpotyViewController {
    CGPoint _startContentOffset;
    UIImage *_image;
}

- (instancetype)initWithMainImage:(UIImage *)image {
    if(self = [super init]) {
        _image = [image copy];
        _mainImageView = [UIImageView new];
        [_mainImageView setImage:_image];
        _overView = [UIView new];
        _tableView = [UITableView new];
    }
    
    return self;
}

- (void)loadView
{
    //Create the view
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [view setBackgroundColor:[UIColor grayColor]];
    
    //Configure the view
    [_mainImageView setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.width)];
    [_mainImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_mainImageView setImageToBlur:_image blurRadius:kLBBlurredImageDefaultBlurRadius completionBlock:nil];
    [view addSubview:_mainImageView];
    
    [_overView setFrame:_mainImageView.bounds];
    [_overView setBackgroundColor:[UIColor clearColor]];
    [view addSubview:_overView];
    
    [_tableView setFrame:view.frame];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [view addSubview:_tableView];
    
    _startContentOffset = CGPointMake(0, -_overView.bounds.size.height);
    [_tableView setContentInset:UIEdgeInsetsMake(_overView.bounds.size.height, 0, 0, 0)];
    
    //Set the view
    self.view = view;
}

#pragma mark - Properties Methods

- (void)setOverView:(UIView *)overView {
    static NSUInteger subviewTag = 100;
    UIView *subView = [overView viewWithTag:subviewTag];
    
    if(![subView isEqual:overView]) {
        [subView removeFromSuperview];
        [_overView addSubview:overView];
    }
}


#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //If the user is pulling down
    if(scrollView.contentOffset.y <= _startContentOffset.y) {
        
        //Image size effects
        //CGFloat absoluteY = ABS(scrollView.contentOffset.y);
        CGFloat diff = _startContentOffset.y - scrollView.contentOffset.y;
        
        [_mainImageView setFrame:CGRectMake(0.0-diff/2.0, 0.0, _overView.frame.size.width+diff, _overView.frame.size.height+diff)];
        [_overView setFrame:CGRectMake(0.0, 0.0+diff, _overView.frame.size.width, _overView.frame.size.height)];
        
        
        if(scrollView.contentOffset.y < _startContentOffset.y-kMGOffsetEffects) {
            diff = kMGOffsetEffects;
        }
        
        //Image blur effects
        CGFloat scale = kLBBlurredImageDefaultBlurRadius/kMGOffsetEffects;
        CGFloat newBlur = kLBBlurredImageDefaultBlurRadius - diff*scale;
        
        __block typeof (_overView) overView = _overView;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mainImageView setImageToBlur:_image blurRadius:newBlur completionBlock:nil];
            //Opacity overView
            CGFloat scale = 1.0/kMGOffsetEffects;
            [overView setAlpha:1.0 - diff*scale];
        });
        
        
    //Else if the user is pushing up
    } else if(scrollView.contentOffset.y <= 0) {
        //TableView effects
        [_tableView setContentInset:UIEdgeInsetsMake(ABS(scrollView.contentOffset.y), 0, 0, 0)];
    }
}


#pragma mark - UITableView Delegate & Datasource

/* To override */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setBackgroundColor:[UIColor darkGrayColor]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
    
    [cell.textLabel setText:@"Cell"];
    
    return cell;
}



@end

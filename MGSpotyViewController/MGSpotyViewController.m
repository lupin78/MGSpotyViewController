//
//  MGSpotyViewController.m
//  MGSpotyView
//
//  Created by Matteo Gobbi on 25/06/2014.
//  Copyright (c) 2014 Matteo Gobbi. All rights reserved.
//

#import "MGSpotyViewController.h"
#import "UIImageView+LBBlurredImage.h"

static CGFloat const kMGOffsetEffects = 40.0;


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
    
	CGRect rectFrame = view.frame;
	rectFrame.origin.y = 150;
	rectFrame.size.height -= rectFrame.origin.y;
	
    [_tableView setFrame:rectFrame];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setContentInset:UIEdgeInsetsMake(_mainImageView.frame.size.height-_tableView.frame.origin.y, 0, 0, 0)];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [view addSubview:_tableView];
    
    _startContentOffset = _tableView.contentOffset;
    
    [_overView setFrame:CGRectMake(0, _tableView.frame.origin.y + ABS(_tableView.contentOffset.y) - 100, 320, 100)];
    [_overView setBackgroundColor:[UIColor clearColor]];
	_overView.clipsToBounds = YES;
    [view addSubview:_overView];
    
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
	if (scrollView.contentOffset.y <= 0) {
		//Move the overview
		CGRect overViewRect = _overView.frame;
		overViewRect.origin.y = _tableView.frame.origin.y + ABS(_tableView.contentOffset.y) - overViewRect.size.height;
		[_overView setFrame:overViewRect];
	}
	
    if (scrollView.contentOffset.y <= _startContentOffset.y) {
        
        //Image size effects
        CGFloat diff = _startContentOffset.y - scrollView.contentOffset.y;
        
        [_mainImageView setFrame:CGRectMake(0.0-diff/2.0, 0.0, 320.0+diff, 320.0+diff)];
        
		
		if(scrollView.contentOffset.y < _startContentOffset.y-kMGOffsetEffects) {
			diff = kMGOffsetEffects;
		}
		
		//Image blur effects
		CGFloat scale = kLBBlurredImageDefaultBlurRadius/kMGOffsetEffects;
		CGFloat newBlur = kLBBlurredImageDefaultBlurRadius - diff*scale;
		
		__block typeof (_overView) overView = _overView;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[_mainImageView setImageToBlur:_image blurRadius:newBlur completionBlock:^{
				//Opacity overView
				CGFloat scale = 1.0/kMGOffsetEffects;
				[overView setAlpha:1.0 - diff*scale];
			}];
		});
		
    }
}


#pragma mark - UITableView Delegate & Datasource

/* To override */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
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

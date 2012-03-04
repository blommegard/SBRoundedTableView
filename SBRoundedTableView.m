//
//  --------------------------------------------
//  Copyright (C) 2012 by Simon Blommegård
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  --------------------------------------------
//
//  SBRoundedTableView.m
//  SBRoundedTableView
//
//  Created by Simon Blommegård on 2012-03-04.
//  Copyright (c) 2012 Simon Blommegård. All rights reserved.
//

#import "SBRoundedTableView.h"
#import <QuartzCore/QuartzCore.h>

static void *SBRoundedTableViewContentSizeObservationContext = &SBRoundedTableViewContentSizeObservationContext;

@interface SBRoundedTableViewMaskView : UIView
@property (nonatomic, unsafe_unretained) SBRoundedTableView *tableView;
@end

@implementation SBRoundedTableViewMaskView
@synthesize tableView = _tableView;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setBackgroundColor:[UIColor clearColor]];
		[self setUserInteractionEnabled:NO];
	}
	
	return self;
}

- (void)setTableView:(SBRoundedTableView *)tableView {
    if (_tableView != tableView) {
        _tableView = tableView;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                    cornerRadius:_tableView.layer.cornerRadius];
	[path fill];
}

@end

@interface SBRoundedTableView ()
@property (nonatomic, strong) SBRoundedTableViewMaskView *maskView;
- (void)setup;
- (void)updateMask;
@end

@implementation SBRoundedTableView
@synthesize maskView = _maskView;
@dynamic cornerRadious;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	if (self = [super initWithFrame:frame style:style])
		[self setup];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder])
		[self setup];
	
	return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentSize"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == SBRoundedTableViewContentSizeObservationContext)
        [self updateMask];
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - Properties

- (CGFloat)cornerRadious {
    return self.layer.cornerRadius;
}

- (void)setCornerRadious:(CGFloat)cornerRadious {
    if (self.cornerRadious != cornerRadious) {
        [self.layer setCornerRadius:cornerRadious];
        [_maskView setNeedsDisplay];
    }
}

#pragma mark - Private

- (void)setup {
	_maskView = [[SBRoundedTableViewMaskView alloc] initWithFrame:CGRectZero];
    [_maskView setTableView:self];
	[self.layer setMask:_maskView.layer];
	[self setShowsVerticalScrollIndicator:NO];
	[self setShowsHorizontalScrollIndicator:NO];
    
    // Works, but yes I know, UIKit is not KVO-safe.
    [self addObserver:self
           forKeyPath:@"contentSize"
              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial)
              context:SBRoundedTableViewContentSizeObservationContext];
}

- (void)updateMask {
	CGRect frame = _maskView.frame;
	if(self.contentSize.height > self.frame.size.height)
		frame.size = self.contentSize;
	else
		frame.size = self.frame.size;

    [_maskView setFrame:frame];
	
	[_maskView setNeedsDisplay];
	[self setNeedsDisplay];
}

@end

//
//  TCDropDownSelectionView.h
//  TCSelectionHeader
//
//  Created by Hong Xie on 27/5/15.
//  Copyright (c) 2015 timecoco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCDropDownSelectionView;

@protocol TCDropDownSelectionViewDelegate <NSObject>

@optional

- (void)dropDownSelectionView:(TCDropDownSelectionView *)selectionView clickButtonWithTag:(NSInteger)buttonTag;

- (void)dropDownSelectionViewTouchBackgroundView;

@end

@interface TCDropDownSelectionView : UIView

@property (nonatomic, copy) NSMutableArray *titleArray;
@property (nonatomic, copy) NSMutableArray *selectedArray;

@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, assign) BOOL canMultipleSelect;

@property (nonatomic, weak) id<TCDropDownSelectionViewDelegate> delegate;

- (void)setButtonSelectedWithTag:(NSInteger)tag;

- (void)showFromView:(UIView *)view;
- (void)dismissView;

@end

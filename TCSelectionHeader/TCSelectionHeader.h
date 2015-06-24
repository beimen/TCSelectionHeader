//
//  TCSelectionHeader.h
//  TCSelectionHeader
//
//  Created by Hong Xie on 28/5/15.
//  Copyright (c) 2015 timecoco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCDropDownSelectionView.h"

typedef NS_ENUM(NSInteger, TCSelectionAttachedViewStyle) {
    TCSelectionAttachedViewStyleNone,
    TCSelectionAttachedViewStyleButtonSelection,
    TCSelectionAttachedViewStyleTableSelection
};

typedef NS_ENUM(NSInteger, TCSelectionAttachedAnimationStyle) {
    TCSelectionAttachedAnimationStyleNone,
    TCSelectionAttachedAnimationStyleFade,
    TCSelectionAttachedAnimationStyleScrollDown,
    TCSelectionAttachedAnimationStyleScrollUp
};

@class TCSelectionHeader;
@class TCSelectionExpandableItem;

@protocol TCSelectionExpandableItemDelegate <NSObject>

- (void)showItem:(TCSelectionExpandableItem *)item attachedView:(BOOL)show;

@end

@interface TCSelectionExpandableItem : UIButton

@property (nonatomic, getter=isExpanded) BOOL expanded;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) TCDropDownSelectionView *attachedView;
@property (nonatomic, weak) id<TCSelectionExpandableItemDelegate> delegate;

@end

@protocol TCSelectionHeaderDelegate <NSObject>

@required

- (NSInteger)numberOfHeaderItems;

- (NSMutableArray *)selectionHeader:(TCSelectionHeader *)header titleArrayForItemTag:(NSInteger)tag;

@optional

- (void)selectionHeader:(TCSelectionHeader *)header didClickedItem:(TCSelectionExpandableItem *)item;

- (void)selectionHeader:(TCSelectionHeader *)header didClickedButtonTag:(NSInteger)buttonTag ItemTag:(NSInteger)itemTag;

@end

@interface TCSelectionHeader : UIView <TCDropDownSelectionViewDelegate>

@property (nonatomic, assign) CGFloat yOffsetOfcenter;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) NSMutableArray *selectIndexArray;
@property (nonatomic, assign) TCSelectionAttachedAnimationStyle *animationStyle;
@property (nonatomic, assign) TCSelectionAttachedViewStyle *viewStyle;

@property (nonatomic, assign) BOOL isPackupedViews;

@property (nonatomic, weak) id<TCSelectionHeaderDelegate> delegate;

- (void)setSelectIndex:(NSInteger)selectIndex forItemWithTag:(NSInteger)tag;

- (void)packupViews;

@end

//
//  TCSelectionHeader.m
//  TCSelectionHeader
//
//  Created by Hong Xie on 28/5/15.
//  Copyright (c) 2015 timecoco. All rights reserved.
//

#import "TCSelectionHeader.h"

@interface TCSelectionExpandableItem ()

@property (nonatomic, strong) NSMutableArray *itemTitleArray;

@end

@implementation TCSelectionExpandableItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectIndex = 0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if ([self.itemTitleArray count] > 1) {
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -self.imageView.width - 5, 0, self.imageView.width);
        self.imageEdgeInsets = UIEdgeInsetsMake(0, self.titleLabel.width, 0, -self.titleLabel.width - 5);
    } else {
        self.titleEdgeInsets = UIEdgeInsetsZero;
        self.imageEdgeInsets = UIEdgeInsetsZero;
    }
}

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;

    if (_attachedView != nil) {
        [self.delegate showItem:self attachedView:expanded];
        if (!expanded) {
            [self setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"sortArrow"] forState:UIControlStateNormal];
        } else {
            [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"sortArrow_HL"] forState:UIControlStateNormal];
        }
        [self setNeedsLayout];
    }
}

- (void)setAttachedView:(TCDropDownSelectionView *)attachedView {
    _attachedView = attachedView;
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex;

    if ([_itemTitleArray count]) {
        [self setTitle:_itemTitleArray[selectIndex] forState:UIControlStateNormal];
        [_attachedView setButtonSelectedWithTag:selectIndex];
        [self setNeedsLayout];
    }
}

- (void)setItemTitleArray:(NSMutableArray *)itemTitleArray {
    _itemTitleArray = itemTitleArray;

    if ([itemTitleArray count]) {
        self.attachedView.titleArray = itemTitleArray;
        if ([itemTitleArray count] == 1) {
            self.enabled = NO;
            [self.imageView removeFromSuperview];
        } else {
            [self setImage:[UIImage imageNamed:@"sortArrow"] forState:UIControlStateNormal];
        }
        [self setNeedsLayout];
    }
    [self setSelectIndex:0];
}

@end

@interface TCSelectionHeader () <TCSelectionExpandableItemDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableArray *titleArrays;

@end

@implementation TCSelectionHeader

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addSubview:self.containerView];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.containerView.frame = self.bounds;
    [self.itemArray enumerateObjectsUsingBlock:^(TCSelectionExpandableItem *item, NSUInteger idx, BOOL *stop) {
        NSInteger count = [self.itemArray count];
        item.frame = CGRectMake(self.width / count * idx, 0, self.width / count, self.height);
    }];
}

- (void)dealloc {
    NSLog(@"TCSelectionHeader is deallocated.");
}

#pragma mark - Lazy Loading

- (UIView *)containerView {
    if (_containerView == nil) {
        self.containerView = [[UIView alloc] initWithFrame:self.bounds];
        _containerView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_containerView];
    }
    return _containerView;
}

- (NSMutableArray *)itemArray {
    if (_itemArray == nil) {
        self.itemArray = [NSMutableArray new];
    }
    return _itemArray;
}

- (NSMutableArray *)titleArrays {
    if (_titleArrays == nil) {
        self.titleArrays = [NSMutableArray new];
    }
    if ([self.delegate respondsToSelector:@selector(selectionHeader:titleArrayForItemTag:)]) {
        if ([_titleArrays count]) {
            [_titleArrays removeAllObjects];
        }
        for (int idx = 0; idx < [self.delegate numberOfHeaderItems]; idx++) {
            [_titleArrays addObject:(NSMutableArray *) [self.delegate selectionHeader:self titleArrayForItemTag:idx]];
        }
    }
    return _titleArrays;
}

#pragma mark - Setter

- (void)setDelegate:(id<TCSelectionHeaderDelegate>)delegate {
    _delegate = delegate;

    [self setupItems];
}

- (void)setYOffsetOfcenter:(CGFloat)yOffsetOfcenter {
    _yOffsetOfcenter = yOffsetOfcenter;

    //这里可能要添加一个调整按钮位置的方法
}

#pragma mark - Getter

- (NSMutableArray *)selectIndexArray {
    NSMutableArray *selectIndexArray = [NSMutableArray new];
    [self.itemArray enumerateObjectsUsingBlock:^(TCSelectionExpandableItem *item, NSUInteger itemTag, BOOL *stop) {
        [selectIndexArray addObject:@(item.selectIndex)];
    }];
    return selectIndexArray;
}

- (BOOL)isPackupedViews {
    __block BOOL isPackupedViews = YES;
    [self.itemArray enumerateObjectsUsingBlock:^(TCSelectionExpandableItem *item, NSUInteger itemTag, BOOL *stop) {
        if (item.expanded) {
            isPackupedViews = NO;
        }
    }];
    return isPackupedViews;
}

#pragma mark - Setup & Update

- (void)setupItems {
    NSInteger count = [self.delegate numberOfHeaderItems];
    for (int idx = 0; idx < count; idx++) {
        TCSelectionExpandableItem *item = [[TCSelectionExpandableItem alloc] init];
        item.frame = CGRectMake(self.width / count * idx, 0, self.width / count, self.height);
        [item.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [item setBackgroundImage:[UIImage imageFromColor:COMMON_GRAY_COLOR] forState:UIControlStateNormal];
        [item setBackgroundImage:[UIImage imageFromColor:COMMON_LIGHT_GRAY_COLOR] forState:UIControlStateHighlighted];
        [item setTitleColor:COMMON_TEXT_DARK_COLOR forState:UIControlStateNormal];

        item.delegate = self;
        [item setExpanded:NO];

        item.tag = idx;
        [item addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];

        [self.containerView addSubview:item];
        [self.itemArray addObject:item];
    }
    [self.itemArray enumerateObjectsUsingBlock:^(TCSelectionExpandableItem *item, NSUInteger idx, BOOL *stop) {
        [item setItemTitleArray:[self.titleArrays objectAtIndex:idx]];
        [item setTitle:item.itemTitleArray[0] forState:UIControlStateNormal];
    }];
}

- (void)itemClicked:(TCSelectionExpandableItem *)sender {
    if ([self.delegate respondsToSelector:@selector(selectionHeader:didClickedItem:)]) {
        //添加一个attachedView
        if (sender.attachedView == nil) {
            if ([[self.titleArrays objectAtIndex:sender.tag] count] > 1) {
                TCDropDownSelectionView *selectionView = [[TCDropDownSelectionView alloc] initWithFrame:self.bounds];
                selectionView.tag = sender.tag;
                selectionView.titleArray = [self.titleArrays objectAtIndex:sender.tag];
                selectionView.delegate = self;
                [sender setAttachedView:selectionView];
            }
        }
        //委托方法
        [self.delegate selectionHeader:self didClickedItem:sender];
        //对item来进行展开和收起操作
        [sender setExpanded:!sender.isExpanded];
        //展开属性是排他的，只要有一个展开，其余的都禁止展开
        [self.itemArray enumerateObjectsUsingBlock:^(TCSelectionExpandableItem *item, NSUInteger idx, BOOL *stop) {
            if (idx != sender.tag) {
                [item setExpanded:NO];
            }
        }];
    }
}

#pragma mark - Public

//- (void)updateStatusWithButtonTag:(NSInteger)buttonTag withItemTag:(NSInteger)itemTag {
//    TCSelectionExpandableItem *firstItem = self.itemArray[0];
//    TCSelectionExpandableItem *thirdItem = self.itemArray[2];
//    if (itemTag == 0) {
//        if (firstItem.selectIndex != buttonTag) {
//            firstItem.selectIndex = buttonTag;
//            thirdItem.selectIndex = 0;
//        }
//    } else if (itemTag == 2) {
//        if (thirdItem.selectIndex != buttonTag) {
//            thirdItem.selectIndex = buttonTag;
//        }
//    }
//}

- (void)setSelectIndex:(NSInteger)selectIndex forItemWithTag:(NSInteger)tag {
    TCSelectionExpandableItem *item = self.itemArray[tag];
    item.selectIndex = selectIndex;
}

- (void)updateTitleArrayForItemWithTag:(NSInteger)tag {
    TCSelectionExpandableItem *item = self.itemArray[tag];
    item.itemTitleArray = self.titleArrays[tag];
}

- (void)packupViews {
    [self.itemArray enumerateObjectsUsingBlock:^(TCSelectionExpandableItem *item, NSUInteger idx, BOOL *stop) {
        [item setExpanded:NO];
    }];
}

#pragma mark - TCDropDownSelectionView Delegate

//- (BOOL)dropDownSelectionView:(TCDropDownSelectionView *)selectionView enableForButtonWithTag:(NSInteger)buttonTag {
//    BOOL active = YES;
//    if ([self.delegate respondsToSelector:@selector(selectionHeader:validateActiveWithTitle:)]) {
//        NSString *title = [[selectionView.buttonArray objectAtIndex:buttonTag] titleLabel].text;
//        active = [self.delegate selectionHeader:self validateActiveWithTitle:title];
//    }
//    return active;
//}

- (void)dropDownSelectionView:(TCDropDownSelectionView *)selectionView clickButtonWithTag:(NSInteger)buttonTag {
    TCSelectionExpandableItem *item = self.itemArray[selectionView.tag];
    //先收起
    [item setExpanded:NO];
    //更新各自item的tag
    [self setSelectIndex:buttonTag forItemWithTag:selectionView.tag];
    //更新title
    [self.itemArray enumerateObjectsUsingBlock:^(TCSelectionExpandableItem *item, NSUInteger idx, BOOL *stop) {
        if (idx != selectionView.tag) {
            if (idx != 0) {
                [self updateTitleArrayForItemWithTag:idx];
            }
        }
    }];
    //调用委托，委托设置相关的selectIndex
    if ([self.delegate respondsToSelector:@selector(selectionHeader:didClickedButtonTag:ItemTag:)]) {
        [self.delegate selectionHeader:self didClickedButtonTag:buttonTag ItemTag:selectionView.tag];
    }
}

- (void)dropDownSelectionViewTouchBackgroundView {
    [self packupViews];
}

#pragma mark - TCSelectionExpandableItemDelegate

- (void)showItem:(TCSelectionExpandableItem *)item attachedView:(BOOL)show {
    if (show) {
        [item.attachedView showFromView:self];
    } else {
        [item.attachedView dismissView];
    }
}

@end

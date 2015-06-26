//
//  TCDropDownSelectionView.m
//  TCSelectionHeader
//
//  Created by Hong Xie on 27/5/15.
//  Copyright (c) 2015 timecoco. All rights reserved.
//

#import "TCDropDownSelectionView.h"
#import "TCUtility.h"

#define RGB_COLOR(r,g,b)            RGB_COLOR_ALPHA(r,g,b,1)
#define RGB_COLOR_ALPHA(r,g,b,a)    [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]
#define TCDROPDOWNSELECTION_BUTTON_GRAY_COLOR               RGB_COLOR(230, 230, 230)
#define TCDROPDOWNSELECTION_BACKGROUND_COLOR                RGB_COLOR(100, 100, 100)

@interface TCDropDownSelectionButton : UIButton

@property (nonatomic, assign) BOOL canMultipleSelect;

@end

@implementation TCDropDownSelectionButton

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.layer.borderColor = [UIColor redColor].CGColor;
    } else {
        self.layer.borderColor = TCDROPDOWNSELECTION_BUTTON_GRAY_COLOR.CGColor;
    }
}

@end

@interface TCDropDownSelectionView ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *containerView;

@end

@implementation TCDropDownSelectionView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.backgroundColor = [UIColor clearColor];
    self.canMultipleSelect = NO;
    self.clipsToBounds = YES;
    [self addSubview:self.backgroundView];
    [self addSubview:self.containerView];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.buttonArray enumerateObjectsUsingBlock:^(TCDropDownSelectionButton *button, NSUInteger idx, BOOL *stop) {
        button.frame = CGRectMake(8 + (button.tag % 4) * (button.frame.size.width + 8), (button.frame.size.height + 12) * (button.tag / 4) + 12, button.frame.size.width, button.frame.size.height);
    }];
    self.containerView.frame = CGRectMake(self.containerView.frame.origin.x, self.containerView.frame.origin.y, self.containerView.frame.size.width, CGRectGetMaxY([(TCDropDownSelectionButton *) [self.buttonArray lastObject] frame]) + 12);
}

#pragma mark - Setter

- (void)setTitleArray:(NSMutableArray *)titleArray {
    _titleArray = [NSMutableArray arrayWithArray:titleArray];

    [self creatButtons];
}

#pragma mark - Lazy Loading

- (UIView *)containerView {
    if (_containerView == nil) {
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.alpha = 1.0f;
    }
    return _containerView;
}

- (UIView *)backgroundView {
    if (_backgroundView == nil) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _backgroundView.alpha = 0.7f;
        _backgroundView.backgroundColor = TCDROPDOWNSELECTION_BACKGROUND_COLOR;
        [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedAction)]];
    }
    return _backgroundView;
}

- (NSMutableArray *)buttonArray {
    if (_buttonArray == nil) {
        self.buttonArray = [NSMutableArray new];
    }
    return _buttonArray;
}

#pragma mark - Private Methods

- (void)creatButtons {
    assert([self.titleArray count]);

    [self.buttonArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.buttonArray removeAllObjects];

    [self.titleArray enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        TCDropDownSelectionButton *button = [self createButtonWithTitle:title withTag:idx];
        [self.buttonArray addObject:button];
        [self.containerView addSubview:button];
    }];
    [self findDefaultSelection];
    [self setNeedsLayout];
}

- (TCDropDownSelectionButton *)createButtonWithTitle:(NSString *)title withTag:(NSInteger)tag {
    TCDropDownSelectionButton *button = [TCDropDownSelectionButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, (self.frame.size.width - 40) / 4, 40);
    button.layer.cornerRadius = 4.0f;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = TCDROPDOWNSELECTION_BUTTON_GRAY_COLOR.CGColor;
    button.clipsToBounds = YES;

    [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [button setTitleColor:TCDROPDOWNSELECTION_BUTTON_GRAY_COLOR forState:UIControlStateDisabled];
    [button setBackgroundImage:[UIImage imageFromColor:[UIColor redColor]] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageFromColor:[UIColor redColor]] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor]] forState:UIControlStateDisabled];

    button.tag = tag;
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(highlightBorder:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(unhighlightBorder:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(unhighlightBorder:) forControlEvents:UIControlEventTouchDragOutside];

    button.canMultipleSelect = self.canMultipleSelect;
    return button;
}

- (void)buttonClicked:(UIButton *)sender {
    [self setButtonSelectedWithTag:sender.tag];
    if (self.canMultipleSelect) {
    } else {
        if ([self.delegate respondsToSelector:@selector(dropDownSelectionView:clickButtonWithTag:)]) {
            [self.delegate dropDownSelectionView:self clickButtonWithTag:sender.tag];
        }
    }
}

- (void)findDefaultSelection {
    if ([self.selectedArray count]) {
        [self.buttonArray enumerateObjectsUsingBlock:^(TCDropDownSelectionButton *button, NSUInteger idx, BOOL *stop) {
            if ([self.selectedArray indexOfObject:button.titleLabel.text] != NSNotFound) {
                [button setSelected:YES];
            }
        }];
    } else {
        [(TCDropDownSelectionButton *) [self.buttonArray firstObject] setSelected:YES];
    }
}

- (void)highlightBorder:(UIButton *)sender {
    if (!sender.isSelected) {
        sender.layer.borderColor = [UIColor redColor].CGColor;
    }
}

- (void)unhighlightBorder:(UIButton *)sender {
    if (!sender.isSelected) {
        sender.layer.borderColor = TCDROPDOWNSELECTION_BUTTON_GRAY_COLOR.CGColor;
    }
}

- (void)tappedAction {
    if ([self.delegate respondsToSelector:@selector(dropDownSelectionViewTouchBackgroundView)]) {
        [self.delegate dropDownSelectionViewTouchBackgroundView];
    }
}

- (void)showView {
    self.hidden = NO;
    self.backgroundView.alpha = 0.0f;
    self.containerView.frame = CGRectMake(self.containerView.frame.origin.x, -self.containerView.frame.size.height, self.containerView.frame.size.width, self.containerView.frame.size.height);
    [UIView animateWithDuration:0.25f
                     animations:^{
                         self.backgroundView.alpha = 0.7f;
                         self.containerView.frame = CGRectMake(self.containerView.frame.origin.x, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         self.hidden = NO;
                     }];
}

#pragma mark - Public Methods

- (void)dismissView {
    [UIView animateWithDuration:0.25f
                     animations:^{
                         self.backgroundView.alpha = 0.0f;
                         self.containerView.frame = CGRectMake(self.containerView.frame.origin.x, -self.containerView.frame.size.height, self.containerView.frame.size.width, self.containerView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                     }];
}

- (void)showFromView:(UIView *)view {
    UIView *targetView = [[UIApplication sharedApplication].delegate.window.rootViewController view];
    [targetView addSubview:self];
    CGRect convertedRect = [targetView convertRect:view.frame toView:targetView];
    self.frame = CGRectMake(self.frame.origin.x, convertedRect.origin.y + convertedRect.size.height, self.frame.size.width, self.frame.size.height);
    [self showView];
}

- (void)setButtonSelectedWithTag:(NSInteger)tag {
    [self.buttonArray enumerateObjectsUsingBlock:^(TCDropDownSelectionButton *button, NSUInteger idx, BOOL *stop) {
        if (self.canMultipleSelect) {
            if (tag == idx) {
                [button setSelected:NO];
            } else {
                [button setSelected:YES];
            }
        } else {
            if (tag == idx) {
                [button setSelected:YES];
            } else {
                [button setSelected:NO];
            }
        }
    }];
}

@end

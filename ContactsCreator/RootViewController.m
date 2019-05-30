//
//  RootViewController.m
//  ContactsCreator
//
//  Created by Vladimir Ozerov on 23/08/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import "RootViewController.h"
#import "ContactsCreator.h"


typedef void (^ButtonActionBlock)(void);


@interface RootViewController ()

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSMutableArray<ButtonActionBlock> *actionBlocksList;

@property (nonatomic, strong) ContactsCreator *contactsCreator;

@end


@implementation RootViewController


#pragma mark - Life cycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		self.navigationItem.title = @"📒 Contacts Creator";
		
		_actionBlocksList = [NSMutableArray array];
		_contactsCreator = [ContactsCreator new];
	}
	return self;
}


#pragma mark - View life cycle

- (void)loadView
{
	UIView *view = [UIView new];
	view.backgroundColor = UIColor.whiteColor;
	
	UIStackView *stackView = [self createStackView];
	[view addSubview:stackView];
	
	self.view = view;
	self.stackView = stackView;
	
	[self setUpConstraints];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self createFlexibleSpacing];
	
	[self createButtonWithTitle:@"Create 50x" actionBlock:^{
		[self.contactsCreator executeWithCount:50];
		[self animateHiding:5];
	}];
	[self createButtonWithTitle:@"Create 300x" actionBlock:^{
		[self.contactsCreator executeWithCount:300];
		[self animateHiding:10];
	}];
	[self createButtonWithTitle:@"Create 1500x" actionBlock:^{
		[self.contactsCreator executeWithCount:1500];
		[self animateHiding:30];
	}];
	[self createButtonWithTitle:@"Create 30000x" actionBlock:^{
		[self.contactsCreator executeWithCount:30000];
		[self animateHiding:60];
	}];

	[self createFlexibleSpacing];
}


#pragma mark - UI creation

- (UIStackView *)createStackView
{
	UIStackView *stackView = [UIStackView new];
	stackView.axis = UILayoutConstraintAxisVertical;
	stackView.distribution = UIStackViewDistributionFillProportionally;
	stackView.alignment = UIStackViewAlignmentCenter;
	stackView.spacing = 30.0;
	stackView.translatesAutoresizingMaskIntoConstraints = NO;
	return stackView;
}

- (void)createFlexibleSpacing
{
	UIView *view = [UIView new];
	view.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints:@[
		[view.widthAnchor constraintEqualToConstant:1],
		[view.heightAnchor constraintGreaterThanOrEqualToConstant:1]
	]];
	[self.stackView addArrangedSubview:view];
}

- (void)createButtonWithTitle:(NSString *)title actionBlock:(ButtonActionBlock)actionBlock
{
	[self.actionBlocksList addObject:[actionBlock copy]];
	
	UIButton *button = [UIButton new];
	button.backgroundColor = UIColor.blackColor;
	button.titleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightRegular];
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
	[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
	
	const CGSize fetchButtonSize = CGSizeMake(200.0, 60.0);
	button.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints:@[
		[button.widthAnchor constraintEqualToConstant:fetchButtonSize.width],
		[button.heightAnchor constraintEqualToConstant:fetchButtonSize.height]
	]];
	
	[self.stackView addArrangedSubview:button];
}

- (void)setUpConstraints
{
	NSLayoutAnchor *topAnchor = nil;
	NSLayoutAnchor *bottomAnchor = nil;
	if (@available(iOS 11.0, *))
	{
		UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
		topAnchor = safeArea.topAnchor;
		bottomAnchor = safeArea.bottomAnchor;
	}
	else
	{
		topAnchor = self.topLayoutGuide.bottomAnchor;
		bottomAnchor = self.bottomLayoutGuide.topAnchor;
	}
	
	[NSLayoutConstraint activateConstraints:@[
		[self.stackView.topAnchor constraintEqualToAnchor:topAnchor],
		[self.stackView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
		[self.stackView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
		[self.stackView.bottomAnchor constraintEqualToAnchor:bottomAnchor]
	]];
}


#pragma mark - Actions

- (void)buttonAction:(UIButton *)button
{
	NSUInteger indexOfButton = [self.stackView.arrangedSubviews indexOfObject:button] - 1;
	if (indexOfButton == NSNotFound || indexOfButton >= self.actionBlocksList.count)
	{
		return;
	}
	
	self.actionBlocksList[indexOfButton]();
}

- (void)animateHiding:(NSTimeInterval)duration
{
	[UIView animateWithDuration:duration
					 animations:^{
						 self.view.alpha = 0;
						 self.view.transform = CGAffineTransformMakeScale(0.3, 0.3);
					 } completion:nil];
}

@end

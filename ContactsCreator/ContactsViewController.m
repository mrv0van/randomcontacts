//
//  ContactsViewController.m
//  ContactsCreator
//
//  Created by Vladimir Ozerov on 23/08/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactsCreator.h"


static const CGSize ButtonSize = { 220, 80 };
static const CGFloat ButtonSpacing = 15;


@interface ContactsViewController ()

@property (nonatomic, strong) ContactsCreator *contactsCreator;

@end


@implementation ContactsViewController

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_contactsCreator = [ContactsCreator new];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIButton *topButton = [UIButton new];
	topButton.backgroundColor = [UIColor blackColor];
	topButton.titleLabel.font = [UIFont systemFontOfSize:25 weight:UIFontWeightUltraLight];
	[topButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[topButton setTitle:@"50 контактов" forState:UIControlStateNormal];
	[topButton addTarget:self action:@selector(smallAmount) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:topButton];
	
	UIButton *midButton = [UIButton new];
	midButton.backgroundColor = [UIColor blackColor];
	midButton.titleLabel.font = [UIFont systemFontOfSize:25 weight:UIFontWeightMedium];
	[midButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[midButton setTitle:@"300 контактов" forState:UIControlStateNormal];
	[midButton addTarget:self action:@selector(midAmount) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:midButton];

	UIButton *bottomButton = [UIButton new];
	bottomButton.backgroundColor = [UIColor blackColor];
	bottomButton.titleLabel.font = [UIFont systemFontOfSize:25 weight:UIFontWeightHeavy];
	[bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[bottomButton setTitle:@"1500 контактов" forState:UIControlStateNormal];
	[bottomButton addTarget:self action:@selector(bigAmount) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:bottomButton];
	
	topButton.translatesAutoresizingMaskIntoConstraints = NO;
	[topButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
	[topButton.bottomAnchor constraintEqualToAnchor:midButton.topAnchor constant:-ButtonSpacing].active = YES;
	[topButton.widthAnchor constraintEqualToConstant:ButtonSize.width].active = YES;
	[topButton.heightAnchor constraintEqualToConstant:ButtonSize.height].active = YES;

	midButton.translatesAutoresizingMaskIntoConstraints = NO;
	[midButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
	[midButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
	[midButton.widthAnchor constraintEqualToConstant:ButtonSize.width].active = YES;
	[midButton.heightAnchor constraintEqualToConstant:ButtonSize.height].active = YES;
	
	bottomButton.translatesAutoresizingMaskIntoConstraints = NO;
	[bottomButton.topAnchor constraintEqualToAnchor:midButton.bottomAnchor constant:ButtonSpacing].active = YES;
	[bottomButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
	[bottomButton.widthAnchor constraintEqualToConstant:ButtonSize.width].active = YES;
	[bottomButton.heightAnchor constraintEqualToConstant:ButtonSize.height].active = YES;
}

- (void)smallAmount
{
	[self.contactsCreator executeWithCount:50];
	[self animateHiding:10];
}

- (void)midAmount
{
	[self.contactsCreator executeWithCount:300];
	[self animateHiding:30];
}

- (void)bigAmount
{
	[self.contactsCreator executeWithCount:1500];
	[self animateHiding:120];
}

- (void)animateHiding:(NSTimeInterval)duration
{
	[UIView animateWithDuration:duration
						  delay:0
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 self.view.alpha = 0;
						 self.view.transform = CGAffineTransformMakeScale(0.3, 0.3);
					 } completion:nil];
}

@end

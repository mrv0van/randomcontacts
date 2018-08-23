//
//  ContactsViewController.m
//  ContactsCreator
//
//  Created by Vladimir Ozerov on 23/08/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactsCreator.h"


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
	
	[self.contactsCreator execute];
}

@end

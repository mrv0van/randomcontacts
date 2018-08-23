//
//  AppDelegate.m
//  Created by ozermanious on 17.11.14.
//  Copyright (c) 2014 SberTech. All rights reserved.
//

#import "AppDelegate.h"
#import "ContactsViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.window.rootViewController = [ContactsViewController new];
	[self.window makeKeyAndVisible];
	return YES;
}

@end

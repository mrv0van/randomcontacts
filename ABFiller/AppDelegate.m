//
//  AppDelegate.m
//  Created by ozermanious on 17.11.14.
//  Copyright (c) 2014 SberTech. All rights reserved.
//

#import "AppDelegate.h"

@import AddressBook;


@implementation AppDelegate
{
	ABAddressBookRef addressBook;
}

- (void)dealloc
{
	CFRelease(addressBook);
	[super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_window.rootViewController = [[UIViewController new] autorelease];
	[_window makeKeyAndVisible];
	
	[self getAddressBook];
	return YES;
}

- (void)getAddressBook
{
	printf("Accessing address book...");
	addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
	if (ABAddressBookGetAuthorizationStatus != NULL)
	{
		switch (ABAddressBookGetAuthorizationStatus())
		{
			case kABAuthorizationStatusNotDetermined:
			{
				ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
					if (granted)
					{
						printf(" access granted =D\n");
						[self fillAddressBook];
					}
					else
					{
						printf(" access denied :(\n");
					}
				});
				break;
			}
			case kABAuthorizationStatusAuthorized:
			{
				printf(" already have :|\n");
				[self fillAddressBook];
				break;
			}
			default:
			{
				printf(" i don't know!\n");
				break;
			}
		}
	}
}

- (void)fillAddressBook
{
	printf("Filling address book...");
	
	static const NSString *ABFirstName = @"first";
	static const NSString *ABLastName  = @"last";
	static const NSString *ABEmail     = @"email";
	static const NSString *ABPhone     = @"phone";
	NSArray *contacts = @[
		@{ ABFirstName:@"Деймон",   ABLastName:@"Ватсон",       ABEmail:@"damon@test.com",       ABPhone:@"+7 (900) 100-00-00" },
		@{ ABFirstName:@"Неил",     ABLastName:@"Тунниклиф",    ABEmail:@"neil@test.com",        ABPhone:@"+7 (900) 200-00-00" },
		@{ ABFirstName:@"Томас",    ABLastName:@"Ремвик Аасен", ABEmail:@"tra@test.com",         ABPhone:@"+7 (900) 300-00-00" },
		@{ ABFirstName:@"Винсент",  ABLastName:@"Херманс",      ABEmail:@"hermance@test.com",    ABPhone:@"+7 (900) 400-00-00" },
		@{ ABFirstName:@"Жиль",     ABLastName:@"Костильо",     ABEmail:@"cousteller@test.com",  ABPhone:@"+7 (900) 500-00-00" },
		@{ ABFirstName:@"Бенито",   ABLastName:@"Рос",          ABEmail:@"bros@test.com",        ABPhone:@"+7 (900) 600-00-00" },
		@{ ABFirstName:@"Кенни",    ABLastName:@"Белей",        ABEmail:@"belaey@test.com",      ABPhone:@"+7 (900) 700-00-00" },
		@{ ABFirstName:@"Орильен",  ABLastName:@"Фонтеной",     ABEmail:@"fontenua@test.com",    ABPhone:@"+7 (900) 800-00-00" },
		@{ ABFirstName:@"Абель",    ABLastName:@"Мустиестес",   ABEmail:@"abel@test.com",        ABPhone:@"+7 (900) 900-00-00" },
		@{ ABFirstName:@"Владимир", ABLastName:@"Озеров",       ABEmail:@"ozermanious@test.com", ABPhone:@"+7 (916) 345-88-94" },
		@{ ABFirstName:@"Антон",    ABLastName:@"Серебряков",   ABEmail:@"serebryakov@test.com", ABPhone:@"+7 (916) 378-46-87" },
		@{ ABFirstName:@"Максим",   ABLastName:@"Рыжов",        ABEmail:@"rijov@test.com",       ABPhone:@"+7 (967) 241-83-66" },
	];
	
	[contacts enumerateObjectsUsingBlock:^(NSDictionary *contact, NSUInteger idx, BOOL *stop) {
		ABRecordRef record = ABPersonCreate();
		
		ABRecordSetValue(record, kABPersonFirstNameProperty, contact[ABFirstName], NULL);
		ABRecordSetValue(record, kABPersonLastNameProperty, contact[ABLastName], NULL);
		
		ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABStringPropertyType);
		ABMultiValueAddValueAndLabel(email, contact[ABEmail], kABHomeLabel, NULL);
		ABRecordSetValue(record, kABPersonEmailProperty, email, NULL);
		
		ABMutableMultiValueRef phone = ABMultiValueCreateMutable(kABStringPropertyType);
		ABMultiValueAddValueAndLabel(phone, contact[ABPhone], kABHomeLabel, NULL);
		ABRecordSetValue(record, kABPersonPhoneProperty, phone, NULL);
		
		ABAddressBookAddRecord(addressBook, record, NULL);
	}];
	ABAddressBookSave(addressBook, NULL);
	printf(" done!");
}

@end

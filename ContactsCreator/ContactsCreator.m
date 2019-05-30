//
//  ContactsCreator.m
//  ContactsCreator
//
//  Created by Vladimir Ozerov on 23/08/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import "ContactsCreator.h"
@import Contacts;
@import UIKit;


#define NOT_SET ((id)[NSNull null])


static const uint32_t CatAvatarCount = 44;


typedef NSArray<NSString *> MetaContact;
typedef NS_ENUM(NSUInteger, MetaContactIndex) {
	MetaContactIndexGivenName   = 0,
	MetaContactIndexFamilyName  = 1,
	MetaContactIndexEmailMain   = 2,
	MetaContactIndexEmailSecond = 3,
	MetaContactIndexPhoneMain   = 4,
	MetaContactIndexPhoneSecond = 5,
	MetaContactIndexAvatar      = 6,
};


#define CLogLn(FORMAT, ...) fprintf(stderr, "\n%s", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#define CLog(FORMAT, ...) fprintf(stderr, "%s", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);


@interface ContactsCreator ()

@property (nonatomic, strong) CNContactStore *contactStore;
@property (nonatomic, assign) NSUInteger contactsCount;

@property (nonatomic, copy) NSDictionary<NSString *, NSArray<NSString *> *> *catalog;

@end


@implementation ContactsCreator

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_contactStore = [CNContactStore new];
		
		NSURL *catalogURL = [[NSBundle mainBundle] URLForResource:@"Catalog" withExtension:@"plist"];
		_catalog = (id)[NSDictionary dictionaryWithContentsOfURL:catalogURL];
	}
	return self;
}


#pragma mark - Actions

- (void)executeWithCount:(NSUInteger)contactsCount
{
	self.contactsCount = contactsCount;
	
	CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
	switch (status)
	{
		case CNAuthorizationStatusNotDetermined:
		{
			[self.contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
				if (!granted)
				{
					CLogLn(@"🛑\tCNContactStore access required.");
					exit(1);
				}
				[self performChanges];
			}];
			break;
		}
		case CNAuthorizationStatusRestricted:
		case CNAuthorizationStatusDenied:
		{
			CLogLn(@"⚠️\tChange CNContactStore permission in settings.");
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
											   options:@{}
									 completionHandler:nil];
			break;
		}
		case CNAuthorizationStatusAuthorized:
		{
			[self performChanges];
			break;
		}
	}
}


#pragma mark - Routine

- (void)performChanges
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[self deleteAllContacts];
		[self createCustomContacts];
		[self createRandomContacts];
		CLogLn(@"✅\tAll Done.");
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			exit(0);
		});
	});
}

- (void)deleteAllContacts
{
	CLogLn(@"\tDeleting contacts...");
	NSMutableArray<CNContact *> *contactList = [NSMutableArray array];
	CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[]];
	[self.contactStore enumerateContactsWithFetchRequest:fetchRequest
												   error:nil
											  usingBlock:^(CNContact *contact, BOOL *stop) {
												  [contactList addObject:contact];
											  }];
	
	CNSaveRequest *saveRequest = [CNSaveRequest new];
	for (CNContact *contact in contactList)
	{
		[saveRequest deleteContact:[contact mutableCopy]];
	}
	[self performSaveRequest:saveRequest];
	CLog(@" done.");
}

- (CNMutableContact *)contactWithMetaContact:(MetaContact *)metaContact
{
	CNMutableContact *contact = [CNMutableContact new];
	
	NSString *givenName = metaContact[MetaContactIndexGivenName];
	if (givenName != NOT_SET)
	{
		contact.givenName = givenName;
	}

	NSString *familyName = metaContact[MetaContactIndexFamilyName];
	if (familyName != NOT_SET)
	{
		contact.familyName = familyName;
	}
	
	NSMutableArray<CNLabeledValue<NSString *> *> *emailAddresses = [NSMutableArray array];
	NSString *mainEmail = metaContact[MetaContactIndexEmailMain];
	if (mainEmail != NOT_SET)
	{
		[emailAddresses addObject:[CNLabeledValue labeledValueWithLabel:nil
																  value:mainEmail]];
	}
	NSString *secondEmail = metaContact[MetaContactIndexEmailSecond];
	if (secondEmail != NOT_SET)
	{
		[emailAddresses addObject:[CNLabeledValue labeledValueWithLabel:nil
																  value:secondEmail]];
	}
	if (emailAddresses.count)
	{
		contact.emailAddresses = [emailAddresses copy];
	}

	NSMutableArray<CNLabeledValue<NSString *> *> *phoneNumbers = [NSMutableArray array];
	NSString *mainPhone = metaContact[MetaContactIndexPhoneMain];
	if (mainPhone != NOT_SET)
	{
		CNPhoneNumber *phoneNumber = [CNPhoneNumber phoneNumberWithStringValue:mainPhone];
		[phoneNumbers addObject:[CNLabeledValue labeledValueWithLabel:nil
																value:phoneNumber]];
	}
	NSString *secondPhone = metaContact[MetaContactIndexPhoneSecond];
	if (secondPhone != NOT_SET)
	{
		CNPhoneNumber *phoneNumber = [CNPhoneNumber phoneNumberWithStringValue:secondPhone];
		[phoneNumbers addObject:[CNLabeledValue labeledValueWithLabel:nil
																value:phoneNumber]];
	}
	if (phoneNumbers.count)
	{
		contact.phoneNumbers = [phoneNumbers copy];
	}
	
	NSString *avatarName = metaContact[MetaContactIndexAvatar];
	if (avatarName != NOT_SET)
	{
		UIImage *image = [UIImage imageNamed:avatarName];
		NSData *imageData = UIImagePNGRepresentation(image);
		NSAssert(imageData != nil, @"Image not found: %@", avatarName);
		contact.imageData = imageData;
	}

	return contact;
}

- (void)addMetaContacts:(NSArray<MetaContact *> *)metaContactList
{
	CNSaveRequest *saveRequest = [CNSaveRequest new];
	for (MetaContact *metaContact in metaContactList)
	{
		CNMutableContact *contact = [self contactWithMetaContact:metaContact];
		[saveRequest addContact:contact toContainerWithIdentifier:nil];
	}
	[self performSaveRequest:saveRequest];
}

- (void)performSaveRequest:(CNSaveRequest *)saveRequest
{
	NSError *error = nil;
	[self.contactStore executeSaveRequest:saveRequest error:&error];
	if (error)
	{
		CLogLn(@"🛑\tFailed.\n%@", error);
		exit(1);
	}
}


#pragma mark - Contacts generating

- (void)createCustomContacts
{
	CLogLn(@"\tCreating custom contacts...");
	
	NSArray<MetaContact *> *metaContactList = @[
		// FIRST_NAME    LAST_NAME           EMAIL_1                   EMAIL_2             PHONE_1                PHONE_2                AVATAR
		// Разработчики
		@[ @"Владимир",  @"Озеров",          @"ozermanious@test.com",  @"mrv0van@test.ru", @"+7 (916) 345-88-94", @"+7 (917) 844-07-30", @"Kianu"           ],
		@[ @"Антон",     @"Серебряков",      @"serebryakov@test.com",  NOT_SET,            @"+7 (916) 378-46-87", @"+7 (904) 753-93-83", @"Crazyman.jpg"    ],
		@[ @"Максим",    @"Рыжов",           @"rijov.maxim@test.com",  NOT_SET,            @"+7 (967) 241-83-66", @"+7 (999) 800-70-68", @"Boss.jpg"        ],
		@[ @"Сергей",    @"Марчуков",        @"marchukov@test.com",    NOT_SET,            @"+7 (999) 800-19-91", NOT_SET,               @"Developer.jpg"   ],
		@[ @"Алексей",   @"Леванов",         @"levanov@test.com",      NOT_SET,            @"+7 (915) 077-97-49", NOT_SET,               @"Flash.jpg"       ],
		@[ @"Дмитрий",   @"Сакал",           @"sakalthebest@test.com", NOT_SET,            @"+7 (903) 230-94-61", NOT_SET,               @"Snowboard.jpg"   ],
		// Сверхлюди
		@[ @"Чак",       @"Норрис",          @"ch@ck.norris",          NOT_SET,            @"+7 (999) 999-99-99", NOT_SET,               @"ChackNorris.jpg" ],
		@[ @"Герман",    @"Греф",            @"gref@gmail.com",        NOT_SET,            @"+7 (900) 000-00-00", NOT_SET,               @"Gref.jpg"        ],
		// Простые
		@[ @"Президент", NOT_SET,            @"mrprezident@russia.ru", NOT_SET,            @"+7 (911) 111-11-11", NOT_SET,               NOT_SET            ],
		@[ NOT_SET,      @"Премьер-министр", @"mrministr@russia.ru",   NOT_SET,            @"+7 (922) 222-22-22", NOT_SET,               NOT_SET            ],
		// Мутные
		@[ @"%2%&^*",    @"2(&@#2",          @"hoho@mail.ru",          NOT_SET,            @"+7 (943) 412-23-54", NOT_SET,               NOT_SET            ],
		@[ @" $#@1 ",    @" ^@123 ",         @"haha@gmail.com",        NOT_SET,            @"+7 (935) 365-68-24", NOT_SET,               NOT_SET            ],
		// Дубликаты
		@[ @"Президент", NOT_SET,            @"mrprezident@russia.ru", NOT_SET,            @"+7 (911) 111-11-11", NOT_SET,               NOT_SET            ],
		@[ @"President", NOT_SET,            @"mrprezident@russia.ru", NOT_SET,            @"+7 (911) 111-11-11", NOT_SET,               NOT_SET            ],
		@[ NOT_SET,      @"Премьер-министр", @"mrministr@russia.ru",   NOT_SET,            @"+7 (922) 222-22-22", NOT_SET,               NOT_SET            ],
	];

	[self addMetaContacts:metaContactList];
	CLog(@" done.");
}

- (void)createRandomContacts
{
	CLogLn(@"\tCreating %@ random contacts", @(self.contactsCount));
	const NSUInteger saveRequestSize = (NSUInteger)sqrtf((float)self.contactsCount);
	
	NSMutableArray<MetaContact *> *metaContactList = [NSMutableArray array];
	for (NSUInteger contactIndex = 0; contactIndex < self.contactsCount; contactIndex++)
	{
		NSString *givenName      = [self randomGivenName];
		NSString *familyName     = [self randomFamilyName];
		NSString *mainEmail      = [self mainEmailWithGivenName:givenName familyName:familyName];
		NSString *secondaryEmail = [self secondaryEmailWithGivenName:givenName familyName:familyName];
		NSString *mainPhone      = [self randomMainPhoneNumber];
		NSString *secondaryPhone = [self randomSecondaryPhoneNumber];
		NSString *avatarString   = [self randomAvatarString];

		NSArray<NSString *> *metaContact = @[
			givenName,
			familyName,
			mainEmail,
			secondaryEmail,
			mainPhone,
			secondaryPhone,
			avatarString
		];
		[metaContactList addObject:[metaContact copy]];
		
		if (metaContactList.count >= saveRequestSize)
		{
			[self addMetaContacts:metaContactList];
			[metaContactList removeAllObjects];
			CLog(@".");
		}
	}
	
	if (metaContactList.count)
	{
		[self addMetaContacts:metaContactList];
	}
	CLog(@" done.");
}

- (NSString *)randomGivenName
{
	const NSArray<NSString *> *givenNamesCollection = self.catalog[@"Given Names"];
	uint32_t givenNamesCount = (uint32_t)givenNamesCollection.count;

	NSUInteger givenNameRandomIndex = arc4random_uniform(givenNamesCount);
	NSString *givenName = givenNamesCollection[givenNameRandomIndex];
	return givenName;
}

- (NSString *)randomFamilyName
{
	if (arc4random_uniform((uint32_t)self.contactsCount / 2) == 0)
	{
		return NOT_SET;
	}

	const NSArray<NSString *> *familyNamesCollection = self.catalog[@"Family Names"];
	uint32_t familyNamesCount = (uint32_t)familyNamesCollection.count;

	NSUInteger familyNameRandomIndex = arc4random_uniform(familyNamesCount);
	NSString *familyName = familyNamesCollection[familyNameRandomIndex];
	return familyName;
}

- (NSString *)mainEmailWithGivenName:(NSString *)givenName familyName:(NSString *)familyName
{
	NSString *mainEmail = [@[
		familyName != NOT_SET ? familyName : @"nofamily",
		@"@",
		givenName != NOT_SET ? givenName : @"noname",
		@".ru"
	] componentsJoinedByString:@""].lowercaseString;
	return mainEmail;
}

- (NSString *)secondaryEmailWithGivenName:(NSString *)givenName familyName:(NSString *)familyName
{
	if (arc4random_uniform(2))
	{
		return NOT_SET;
	}
	NSString *secondEmail = [@[
		givenName != NOT_SET ? givenName : @"noname",
		@".",
		familyName != NOT_SET ? familyName : @"nofamily",
		@"@test.ru"
	] componentsJoinedByString:@""].lowercaseString;
	return secondEmail;
}

- (NSString *)randomMainPhoneNumber
{
	return [self randomPhoneNumberWithPrefix:@"+7900"];
}

- (NSString *)randomSecondaryPhoneNumber
{
	if (arc4random_uniform(2))
	{
		return NOT_SET;
	}
	return [self randomPhoneNumberWithPrefix:@"+7911"];
}

- (NSString *)randomPhoneNumberWithPrefix:(NSString *)phoneNumberPrefix
{
	static NSString *phoneNumberToRepeat = nil;
	static uint32_t updateFactor = 0;
	static uint32_t repeatFactor = 0;
	
	if (phoneNumberToRepeat && !arc4random_uniform(repeatFactor))
	{
		return phoneNumberToRepeat;
	}
	
	NSMutableString *mutableString = [phoneNumberPrefix mutableCopy];
	for (NSInteger charIndex = 0; charIndex < 7; charIndex += 1)
	{
		[mutableString appendString:@(arc4random_uniform(10)).stringValue];
	}
	NSString *phoneNumber = [mutableString copy];
	
	if (!phoneNumberToRepeat)
	{
		updateFactor = sqrtf(self.contactsCount);
		repeatFactor = updateFactor;
	}
	if (!phoneNumberToRepeat || !arc4random_uniform(updateFactor))
	{
		phoneNumberToRepeat = phoneNumber;
	}

	return phoneNumber;
}

- (NSString *)randomAvatarString
{
	if (arc4random_uniform(3) > 0)
	{
		return NOT_SET;
	}
	NSString *avatarString = @(arc4random_uniform(CatAvatarCount)).stringValue;
	return avatarString;
}

@end

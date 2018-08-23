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


static const NSUInteger CatAvatarCount = 44;


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

@end


@implementation ContactsCreator

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_contactStore = [CNContactStore new];
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
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
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
	const NSUInteger saveRequestSize = self.contactsCount / 30;
	const NSArray<NSString *> *givenNamesCollection = @[
		@"Зандерлог",	@"Кирсан",		@"Алтудег",		@"Бордех",		@"Щдуырук",		// 1
		@"Айфозавр",	@"Крабхаз",		@"Ктулху",		@"Парофен",		@"Ульрих",		// 2
		@"Ибупрофен",	@"Митрандокл",	@"Цуцхейчуг",	@"Ыкуцфыг",		@"Хъэдякцыф",	// 3
		@"Леголас",		@"Бармалей",	@"Чупакабра",	@"Джон",		@"Фридрих",		// 4
		@"Али",			@"Корвин",		@"Бабай",		@"Йозеф",		@"Гэндальф",	// 5
		@"Фродо",		@"Сэммиум",		@"Перигрин",	@"Мерри",		@"Арагорн",		// 6
		@"Боромир",		@"Фарамир",		@"Леголас",		@"Теоден",		@"Саруман",		// 7
		@"Саурон",		@"Горлум",		@"Смеагорл",	@"Протос",		@"Люк",			// 8
		@"Митрандир",	@"Колобок",		@"Гена",		@"Гимли",		@"Дарин",		// 9
		@"Балин",		@"Двалин",		@"Бильбо",		@"Мерлин",		@"Максимильян",	// 10
		@"Николай",		@"Батут",		@"Оби-Ван",		@"Йода",		@"Квай-Гон",	// 11
		@"Энакин",		@"Хан",			@"Чубакка",		@"Мейс",		@"Боба",		// 12
		@"Джабба",		@"Элон",		@"Брюс",		@"Арнольд",		@"Капитан",		// 13
		@"Генерал",		@"Спанчбоб",	@"Мистер",		@"Кларк",		@"Самый",		// 14
		@"Кот",         @"Омлет",       @"Котофей",     @"Шайтан",      @"Штирлиц",     // 15
		NOT_SET
	];
	const NSArray<NSString *> *familyNamesCollection = @[
		@"Обама",		@"Иванов",		@"Петров",		@"Сидоров",		@"Забугорденко",		// 1
		@"Глупый",		@"Катапультов",	@"Ряженка",		@"Поттер",		@"Грозный",				// 2
		@"Милый",		@"Грустный",	@"Веселый",		@"Прикольный",	@"Квазимода",			// 3
		@"Богатый",		@"Бедный",		@"Костров",		@"Цыган",		@"Царь",				// 4
		@"Эмберский",	@"Серый",		@"Скайуокер",	@"Вейдер",		@"Тесла",				// 5
		@"Цукерберг",	@"Бегущий",		@"Трусливый",	@"Отважный",	@"Безнадежный",			// 6
		@"Джобс",		@"Тьюринг",		@"Победитель",	@"Пошел-есть",	@"Больной",				// 7
		@"Быдлокодер",	@"Скучный",		@"Зануда",		@"Двуличный",	@"Забери-меня-домой",	// 8
		@"Криптонит",	@"Амидала",		@"Сидиус",		@"Органа",		@"Соло",				// 9
		@"Фетт",		@"Хатт",		@"Подгорный",	@"Маск",		@"Безумный",			// 10
		@"Коннор",		@"Вандам",		@"Ли",			@"Чан",			@"Шварценеггер",		// 11
		@"Очевидность",	@"Чмо",			@"Тайсон",		@"Шайтан",		@"Бессмертный",			// 12
		@"Крабс",		@"Кент",		@"Бонд",		@"Галустян",	@"Членс",				// 13
		@"Слоупоук",	@"Криворукий",	@"Гаргантюа",	@"Континуум",	@"Сингулярность",		// 14
		@"Экспресс",    @"Святой",      @"Первый",      @"Второй",      @"Третий",              // 15
		NOT_SET
	];
	
	NSMutableArray<MetaContact *> *metaContactList = [NSMutableArray array];
	
	NSString * (^randomPhone)(NSString *) = ^(NSString *baseString) {
		NSMutableString *phoneString = [baseString mutableCopy];
		for (NSInteger charIndex = 0; charIndex < 7; charIndex += 1)
		{
			[phoneString appendString:@(rand() % 10).stringValue];
		}
		return phoneString;
	};

	for (NSUInteger contactIndex = 0; contactIndex < self.contactsCount; contactIndex++)
	{
		NSMutableArray<NSString *> *metaContact = [NSMutableArray array];
		
		NSUInteger givenNameRandomIndex = rand() % givenNamesCollection.count;
		NSString *givenName = givenNamesCollection[givenNameRandomIndex];
		[metaContact addObject:givenName];

		NSUInteger familyNameRandomIndex = rand() % familyNamesCollection.count;
		NSString *familyName = familyNamesCollection[familyNameRandomIndex];
		[metaContact addObject:familyName];

		NSString *mainEmail = [@[
			familyName != NOT_SET ? familyName : @"nofamily",
			@"@",
			givenName != NOT_SET ? givenName : @"noname",
			@".ru"
		] componentsJoinedByString:@""].lowercaseString;
		[metaContact addObject:mainEmail];
		NSString *secondEmail = NOT_SET;
		if (rand() % 3)
		{
			secondEmail = [@[
				givenName != NOT_SET ? givenName : @"noname",
				@".",
				familyName != NOT_SET ? familyName : @"nofamily",
				@"@test.ru"
			] componentsJoinedByString:@""].lowercaseString;
		}
		[metaContact addObject:secondEmail];

		[metaContact addObject:randomPhone(@"+7900")];
		NSString *secondPhone = NOT_SET;
		if (rand() % 2)
		{
			secondPhone = randomPhone(@"+7901");
		}
		[metaContact addObject:secondPhone];

		NSString *avatarString = NOT_SET;
		if (rand() % 3 < 2)
		{
			avatarString = @(rand() % CatAvatarCount).stringValue;
		}
		[metaContact addObject:avatarString];

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

@end

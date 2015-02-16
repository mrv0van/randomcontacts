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
				printf(" no access!\n");
				exit(1);
				break;
			}
		}
	}
}

- (void)fillAddressBook
{
	printf("Cleaning address book...");
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);

	CFIndex peopleCount = CFArrayGetCount(allPeople);
	for (CFIndex i = 0; i < peopleCount; i += 1)
	{
		ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
		ABAddressBookRemoveRecord(addressBook, person, nil);
	}
	CFRelease(allPeople);
	printf(" done!\n");
	
	printf("Filling address book...");
	
	const NSInteger FirstsCount = 41;
	NSArray *Firsts = @[
		@"Зандерлог",
		@"Кирсан",
		@"Алтудег",
		@"Бордех",
		@"Щдуырук",
		@"Айфозавр",
		@"Крабхаз",
		@"Ктулху",
		@"Парофен",
		@"Ульрих",
		@"Ибупрофен",
		@"Митрандокл",
		@"Цуцхейчуг",
		@"Ыкуцфыг",
		@"Хъэдякцыф",
		@"Леголас",
		@"Бармалей",
		@"Чупакабра",
		@"Джон",
		@"Фридрих",
		
		@"Али",
		@"Корвин",
		@"Бабай",
		@"Йозеф",
		@"Гэндальф",
		@"Фродо",
		@"Сэммиум",
		@"Перигрин",
		@"Мерри",
		@"Арагорн",
		@"Боромир",
		@"Фарамир",
		@"Галадриэль",
		@"Теоден",
		@"Саруман",
		@"Саурон",
		@"Горлум",
		@"Смеагорл",
		@"Протос",
		@"Люк",
		@"Митрандир",
	];
	
	const NSInteger LastsCount = 41;
	NSArray *Lasts = @[
		@"Забугорденко",
		@"Обама",
		@"Иванов",
		@"Петров",
		@"Сидоров",
		@"Глупый",
		@"Катапультов",
		@"Ряженка",
		@"Поттер",
		@"Грозный",
		@"Милый",
		@"Грустный",
		@"Веселый",
		@"Прикольный",
		@"Квазимода",
		@"Богатый",
		@"Бедный",
		@"Костров",
		@"Цыган",
		@"Царь",
		@"Эмберский",
		@"Серый",
		@"Скайуокер",
		@"Вейдер",
		@"Тесла",
		@"Цукерберг",
		@"Бегущий",
		@"Трусливый",
		@"Отважный",
		@"Безнадежный",
		@"Джобс",
		@"Тьюринг",
		@"Победитель",
		@"Пошел-есть",
		@"Больной",
		@"Забери-меня-домой",
		@"Быдлокодер",
		@"Скучный",
		@"Зануда",
		@"Двуличный",
		@"Криптонит",
	];
	
	static const NSString *ABFirstName = @"first";
	static const NSString *ABLastName  = @"last";
	static const NSString *ABEmail     = @"email";
	static const NSString *ABPhone1     = @"phone1";
	static const NSString *ABPhone2    = @"phone2";
	static const NSString *ABImage     = @"image";
	NSMutableArray *contacts = [NSMutableArray array];
	
	for (NSInteger i = 0; i < 50; i += 1)
	{
		NSMutableDictionary *contact = [NSMutableDictionary new];
		contact[ABFirstName] = Firsts[rand() % FirstsCount];
		contact[ABLastName] = Lasts[rand() % LastsCount];

		contact[ABPhone1] = ({
			NSMutableString *phoneString = [NSMutableString stringWithString:@"79"];
			for (NSInteger j = 0; j < 9; j += 1)
				[phoneString appendFormat:@"%i", (rand() % 10)];
			[[phoneString copy] autorelease];
		});
		if (i % 2 != 0)
			contact[ABPhone2] = ({
				NSMutableString *phoneString = [NSMutableString stringWithString:@"79"];
				for (NSInteger j = 0; j < 9; j += 1)
					[phoneString appendFormat:@"%i", (rand() % 10)];
				[[phoneString copy] autorelease];
			});
		
		contact[ABEmail] = [@[contact[ABFirstName], @"@", contact[ABLastName], @".ru" ] componentsJoinedByString:@""].lowercaseString;

		contact[ABImage] = [NSString stringWithFormat:@"%li.jpg", (i % 21)];
		
		[(NSMutableArray *)contacts addObject:[contact autorelease]];
	}

	[contacts addObjectsFromArray:@[
		@{ ABPhone1:@"+7 (999) 111-22-33" },
		@{ ABFirstName:@"Владимир", ABLastName:@"Озеров",       ABEmail:@"ozermanious@test.com",  ABPhone1:@"+7 (916) 345-88-94", ABPhone2:@"+7 (917) 844-07-30", ABImage:@"Kianu"    },
		@{ ABFirstName:@"Антон",    ABLastName:@"Серебряков",   ABEmail:@"serebryakov@test.com",  ABPhone1:@"+7 (916) 378-46-87", ABPhone2:@"+7 (904) 753-93-83", ABImage:@"Crazyman.jpg" },
		@{ ABFirstName:@"Максим",   ABLastName:@"Рыжов",        ABEmail:@"rijov.maxim@test.com",  ABPhone1:@"+7 (967) 241-83-66",                                 ABImage:@"Boss.jpg" },
		@{ ABFirstName:@"Сергей",   ABLastName:@"Марчуков",     ABEmail:@"marchukov@test.com",    ABPhone1:@"+7 (999) 814-72-09", ABPhone2:@"+7 (927) 500-89-63", ABImage:@"Developer.jpg" },
		@{ ABFirstName:@"Алексей",  ABLastName:@"Леванов",      ABEmail:@"levanov@test.com",      ABPhone1:@"+7 (915) 077-97-49",                                 ABImage:@"Flash.jpg" },
		@{ ABFirstName:@"Дмитрий",  ABLastName:@"Сакал",        ABEmail:@"sakalthebest@test.com", ABPhone1:@"+7 (903) 230-94-61",                                 ABImage:@"Snowboard.jpg" },
	]];
	
	[contacts enumerateObjectsUsingBlock:^(NSDictionary *contact, NSUInteger idx, BOOL *stop) {
		ABRecordRef record = ABPersonCreate();
		
		ABRecordSetValue(record, kABPersonFirstNameProperty, contact[ABFirstName], NULL);
		ABRecordSetValue(record, kABPersonLastNameProperty, contact[ABLastName], NULL);
		
		ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABStringPropertyType);
		ABMultiValueAddValueAndLabel(email, contact[ABEmail], kABHomeLabel, NULL);
		ABRecordSetValue(record, kABPersonEmailProperty, email, NULL);
		
		ABMutableMultiValueRef phone = ABMultiValueCreateMutable(kABStringPropertyType);
		ABMultiValueAddValueAndLabel(phone, contact[ABPhone1], kABHomeLabel, NULL);
		if (contact[ABPhone2])
			ABMultiValueAddValueAndLabel(phone, contact[ABPhone2], kABWorkLabel, NULL);
		ABRecordSetValue(record, kABPersonPhoneProperty, phone, NULL);
		
		// Image
		if (contact[ABImage])
		{
			UIImage *img = [UIImage imageNamed:contact[ABImage]];
			NSData *dataRef = UIImagePNGRepresentation(img);
			CFDataRef cfDataRef = CFDataCreate(NULL, [dataRef bytes], [dataRef length]);
			ABPersonSetImageData(record, cfDataRef, nil);
		}

		ABAddressBookAddRecord(addressBook, record, NULL);
	}];
	ABAddressBookSave(addressBook, NULL);
	printf(" done!");
	exit(0);
}

@end

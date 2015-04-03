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
	
#if 0
	printf("Randomization contacts enabled!\n");
	srand((unsigned int)time(0));
#endif
	
	printf("Filling address book...\n");
	
	static const NSInteger RandomsCount = 75;
	NSArray *Firsts = @[
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
	];
	BOOL firstsChosen[RandomsCount] = { 0 };
	
	NSArray *Lasts = @[
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
	];
	BOOL lastsChosen[RandomsCount] = { 0 };
	
	static const NSString *ABFirstName = @"first";
	static const NSString *ABLastName  = @"last";
	static const NSString *ABEmail     = @"email";
	static const NSString *ABPhone1     = @"phone1";
	static const NSString *ABPhone2    = @"phone2";
	static const NSString *ABImage     = @"image";
	NSMutableArray *contacts = [NSMutableArray array];
	
	for (NSInteger i = 0; i < RandomsCount; i += 1)
	{
		NSMutableDictionary *contact = [NSMutableDictionary new];
		contact[ABFirstName] = ({
			NSInteger i = rand() % RandomsCount;
			while (firstsChosen[i])
				i = (i + 1) % RandomsCount;
			firstsChosen[i] = YES;
			Firsts[i];
		});
		contact[ABLastName] = ({
			NSInteger i = rand() % RandomsCount;
			while (lastsChosen[i])
				i = (i + 1) % RandomsCount;
			lastsChosen[i] = YES;
			Lasts[i];
		});

		contact[ABPhone1] = ({
			NSMutableString *phoneString = [NSMutableString stringWithString:@"7900"];
			for (NSInteger j = 0; j < 7; j += 1)
				[phoneString appendFormat:@"%i", (rand() % 10)];
			[[phoneString copy] autorelease];
		});
		if (i % 2 != 0)
			contact[ABPhone2] = ({
				NSMutableString *phoneString = [NSMutableString stringWithString:@"7901"];
				for (NSInteger j = 0; j < 7; j += 1)
					[phoneString appendFormat:@"%i", (rand() % 10)];
				[[phoneString copy] autorelease];
			});
		
		contact[ABEmail] = [@[contact[ABFirstName], @"@", contact[ABLastName], @".ru" ] componentsJoinedByString:@""].lowercaseString;
		
		// Например, каждый третий без аватарки
		if (i%3 != 0)
		{
			contact[ABImage] = [NSString stringWithFormat:@"%li.jpg", (i % 33)];
		}
		
		[(NSMutableArray *)contacts addObject:[contact autorelease]];
	}

	[contacts addObjectsFromArray:@[
		@{ ABPhone1:@"+7 (999) 111-22-33" },
		// Разработчики
		@{ ABFirstName:@"Владимир", ABLastName:@"Озеров",       ABEmail:@"ozermanious@test.com",  ABPhone1:@"+7 (916) 345-88-94", ABPhone2:@"+7 (917) 844-07-30", ABImage:@"Kianu"    },
		@{ ABFirstName:@"Антон",    ABLastName:@"Серебряков",   ABEmail:@"serebryakov@test.com",  ABPhone1:@"+7 (916) 378-46-87", ABPhone2:@"+7 (904) 753-93-83", ABImage:@"Crazyman.jpg" },
		@{ ABFirstName:@"Максим",   ABLastName:@"Рыжов",        ABEmail:@"rijov.maxim@test.com",  ABPhone1:@"+7 (967) 241-83-66", ABPhone2:@"+7 (999) 800-70-68", ABImage:@"Boss.jpg" },
		@{ ABFirstName:@"Сергей",   ABLastName:@"Марчуков",     ABEmail:@"marchukov@test.com",    ABPhone1:@"+7 (999) 814-72-09", ABPhone2:@"+7 (927) 500-89-63", ABImage:@"Developer.jpg" },
		@{ ABFirstName:@"Алексей",  ABLastName:@"Леванов",      ABEmail:@"levanov@test.com",      ABPhone1:@"+7 (915) 077-97-49",                                 ABImage:@"Flash.jpg" },
		@{ ABFirstName:@"Дмитрий",  ABLastName:@"Сакал",        ABEmail:@"sakalthebest@test.com", ABPhone1:@"+7 (903) 230-94-61",                                 ABImage:@"Snowboard.jpg" },
		// Сверхлюди
		@{ ABFirstName:@"Чак",      ABLastName:@"Норрис",       ABEmail:@"ch@ck.norris",          ABPhone1:@"+7 (999) 999-99-99",                                 ABImage:@"ChackNorris.jpg" },
		@{ ABFirstName:@"Герман",   ABLastName:@"Греф",         ABEmail:@"gref@gmail.com",        ABPhone1:@"+7 (900) 000-00-00",                                 ABImage:@"Gref.jpg" },
		// Простые
		@{ ABFirstName:@"Президент", ABLastName:[NSNull null],       ABEmail:@"mrprezident@russia.ru", ABPhone1:@"+7 (911) 111-11-11", ABImage:[NSNull null] },
		@{ ABFirstName:[NSNull null], ABLastName:@"Премьер-министр",       ABEmail:@"mrministr@russia.ru", ABPhone1:@"+7 (922) 222-22-22", ABImage:[NSNull null] },
		// Мутные
		@{ ABFirstName:@"%2%&^*", ABLastName:@"2(&@#2", ABEmail:@"hoho@mail.ru", ABPhone1:@"+7 (943) 412-23-54", ABImage:[NSNull null] },
		@{ ABFirstName:@" $#@1 ", ABLastName:@" ^@123 ", ABEmail:@"haha@gmail.com", ABPhone1:@"+7 (935) 365-68-24", ABImage:[NSNull null] },
		@{ ABFirstName:@"Президент", ABLastName:[NSNull null], ABEmail:@"mrprezident@russia.ru", ABPhone1:@"+7 (911) 111-11-11", ABImage:[NSNull null] },
		@{ ABFirstName:[NSNull null], ABLastName:@"Премьер-министр", ABEmail:@"mrministr@russia.ru", ABPhone1:@"+7 (922) 222-22-22", ABImage:[NSNull null] },
	]];
	
	[contacts enumerateObjectsUsingBlock:^(NSDictionary *contact, NSUInteger idx, BOOL *stop) {
		ABRecordRef record = ABPersonCreate();
		
#define EXISTS(VAL) (VAL && (VAL != [NSNull null]))
		
		if (EXISTS(contact[ABFirstName]))
			ABRecordSetValue(record, kABPersonFirstNameProperty, contact[ABFirstName], NULL);
		if (EXISTS(contact[ABLastName]))
			ABRecordSetValue(record, kABPersonLastNameProperty, contact[ABLastName], NULL);
		
		if (EXISTS(contact[ABEmail]))
		{
			ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABStringPropertyType);
			ABMultiValueAddValueAndLabel(email, contact[ABEmail], kABHomeLabel, NULL);
			ABRecordSetValue(record, kABPersonEmailProperty, email, NULL);
		}
		
		if (EXISTS(contact[ABPhone1]) || EXISTS(contact[ABPhone2]))
		{
			ABMutableMultiValueRef phone = ABMultiValueCreateMutable(kABStringPropertyType);
			if (EXISTS(contact[ABPhone1]))
				ABMultiValueAddValueAndLabel(phone, contact[ABPhone1], kABHomeLabel, NULL);
			if (EXISTS(contact[ABPhone2]))
				ABMultiValueAddValueAndLabel(phone, contact[ABPhone2], kABWorkLabel, NULL);
			ABRecordSetValue(record, kABPersonPhoneProperty, phone, NULL);
		}
		
		// Image
		if (EXISTS(contact[ABImage]))
		{
			UIImage *img = [UIImage imageNamed:contact[ABImage]];
			NSData *dataRef = UIImagePNGRepresentation(img);
			CFDataRef cfDataRef = CFDataCreate(NULL, [dataRef bytes], [dataRef length]);
			ABPersonSetImageData(record, cfDataRef, nil);
		}

		ABAddressBookAddRecord(addressBook, record, NULL);
		
		// Прогресс
		printf("%i%% done\n", (int)((float)(idx + 1) / (float)contacts.count * 100));
	}];
	printf("Saving address book...");
	ABAddressBookSave(addressBook, NULL);
	printf(" all done!");
	exit(0);
}

@end

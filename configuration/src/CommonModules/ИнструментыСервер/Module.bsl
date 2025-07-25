///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Создает реквизиты для подключения фонового обновления данных инструмента
//
// Параметры:
//  Форма	 - ФормаКлиентскогоПриложения - форма инструмента
//
Процедура ПриСозданииНаСервере(Форма, ОбновляемаяТаблица, Автообновление = Истина) Экспорт
	
	Модуль = УправлениеИнструментамиРазработкиКлиентСервер;
	
	РеквизитАвтообновление = Новый РеквизитФормы(Модуль.ИмяРеквизитаАвтообновление(), Новый ОписаниеТипов("Булево"));
	РеквизитИмяСтраницы = Новый РеквизитФормы(Модуль.ИмяРеквизитаСтраницаИнструмента(), Новый ОписаниеТипов("Строка"));
	
	ДобавляемыеРеквизиты = Новый Массив;
	ДобавляемыеРеквизиты.Добавить(РеквизитАвтообновление);
	ДобавляемыеРеквизиты.Добавить(РеквизитИмяСтраницы);
		
	Если Автообновление Тогда
		РеквизитДатаОбновления = Новый РеквизитФормы(Модуль.ИмяРеквизитаДатаОбновления(), Новый ОписаниеТипов("Дата"));
		РеквизитТребуетсяОбновление = Новый РеквизитФормы(Модуль.ИмяРеквизитаТребуетсяОбновление(), Новый ОписаниеТипов("Булево"));
		
		ДобавляемыеРеквизиты.Добавить(РеквизитДатаОбновления);
		ДобавляемыеРеквизиты.Добавить(РеквизитТребуетсяОбновление);
	КонецЕсли;
	
	ТипПараметра = ТипЗнч(ОбновляемаяТаблица);
	
	Если ТипПараметра = Тип("Массив") Тогда
		Для Каждого Таблица Из ОбновляемаяТаблица Цикл
			НовыйРеквизит = Новый РеквизитФормы(Модуль.ИмяРеквизитаРезультат(Таблица), Новый ОписаниеТипов("Строка"));
			ДобавляемыеРеквизиты.Добавить(НовыйРеквизит);
		КонецЦикла;
	Иначе
		НовыйРеквизит = Новый РеквизитФормы(Модуль.ИмяРеквизитаРезультат(ОбновляемаяТаблица), Новый ОписаниеТипов("Строка"));
		ДобавляемыеРеквизиты.Добавить(НовыйРеквизит);
	КонецЕсли;
	
	Форма.ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	
	Если ТипПараметра = Тип("Массив") Тогда
		Для Каждого Таблица Из ОбновляемаяТаблица Цикл
			Форма[Модуль.ИмяРеквизитаРезультат(Таблица)] = ПоместитьВоВременноеХранилище(Неопределено, Форма.УникальныйИдентификатор);
		КонецЦикла;
	Иначе
		Форма[Модуль.ИмяРеквизитаРезультат(ОбновляемаяТаблица)] = ПоместитьВоВременноеХранилище(Неопределено, Форма.УникальныйИдентификатор);
	КонецЕсли;
	
	Форма[Модуль.ИмяРеквизитаАвтообновление()] = Автообновление;
	
КонецПроцедуры

// Передает данные из фонового задания клиенту
// 
// Параметры:
//  ДанныеИнструмента - Массив - подготовленные для передачи данные
//  АдресРезультата - Строка - Адрес результата
//  УИДЗамера - Строка - УИДЗамера
//  ДанныеСчетчика - Неопределено, Структура - Данные счетчика
Процедура ОповеститьИнструментОбОбновлении(ДанныеИнструмента = "", АдресРезультата = "", УИДЗамера = "", ДанныеСчетчика = Неопределено) Экспорт
	
	ДанныеУведомления = Новый Структура("ДанныеДерева, УИДЗамера", ДанныеИнструмента, УИДЗамера);
	
	Если ДанныеСчетчика <> Неопределено Тогда
		ДанныеУведомления.Вставить("ДанныеСчетчика", ДанныеСчетчика);
	КонецЕсли;
	
	ПоместитьВоВременноеХранилище(ДанныеУведомления, АдресРезультата);
	
	ФоновоеЗадание = ПолучитьТекущийСеансИнформационнойБазы().ПолучитьФоновоеЗадание();
	
	Адресаты = Новый Массив;
	Адресаты.Добавить(ФоновоеЗадание.НомерРодительскогоСеанса);
	
	УведомленияКлиента.ОтправитьУведомление(ФоновоеЗадание.Ключ, ДанныеУведомления, Адресаты);
	
КонецПроцедуры

// Сериализует дерево или таблицу. Выкидывает поля с незаполненными значениями.
//
// Параметры:
//  Данные				 - ТаблицаЗначений, ДеревоЗначений - данные инструмента
//  КолонкиИнструмента	 - Массив - список колонок инструмента
// 
// Возвращаемое значение:
//  Массив - подготовленные для передачи данные
//
Функция ПодготовитьДанныеИнструментаДляКлиента(Данные, КолонкиИнструмента) Экспорт
	
	Результат = Новый Массив;
	ЭтоДерево = (ТипЗнч(Данные) = Тип("ДеревоЗначений"));
	
	ДанныеДляОбхода = ?(ЭтоДерево, Данные.Строки, Данные);
	
	Для Каждого Строка Из ДанныеДляОбхода Цикл
		ДанныеСтроки = Новый Структура;
		
		Для Каждого Колонка Из КолонкиИнструмента Цикл
			ЗначениеСвойства = Строка[Колонка];
			
			Если ЗначениеЗаполнено(ЗначениеСвойства) Тогда
				ДанныеСтроки.Вставить(Колонка, ЗначениеСвойства);
			КонецЕсли;
		КонецЦикла;
		
		Если ЭтоДерево Тогда
			ОбработатьПодстрокиДерева(ДанныеСтроки, Строка.Строки, КолонкиИнструмента);
		КонецЕсли;
		
		Результат.Добавить(ДанныеСтроки);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ПолучитьДанныеДляПанелиИнструментов() Экспорт
	
	Версия = РегистрыСведений.ВерсииАссетов.ПолучитьТекущуюВерсию(Справочники.ТипыАссетов.НавигационнаяПанель);
	
	Данные = Новый Структура("method, version", "startClient", Версия);
	Данные.Вставить("tools", Справочники.ИнструментыСистемы.СписокИнструментов());
	Данные.Вставить("styles", ИнтерфейсПриложения.ПолучитьДанныеСтилейПодсказок());
	Данные.Вставить("userGUID", XMLСтрока(ПараметрыСеанса.ТекущийПользователь));
	
	Возврат Данные;
	
КонецФункции

// Получить идентификатор инструмента
// 
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - Объект метаданных
// 
// Возвращаемое значение:
//  Строка - идентификатор инструмента
Функция ПолучитьИдентификаторИнструмента(Знач ОбъектМетаданных) Экспорт
	
	Результат = "";
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ИнструментыСистемы.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ИнструментыСистемы КАК ИнструментыСистемы
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ИдентификаторыОбъектовМетаданных КАК ИдентификаторыОбъектовМетаданных
	|		ПО ИнструментыСистемы.ОбъектМетаданных = ИдентификаторыОбъектовМетаданных.Ссылка
	|ГДЕ
	|	ИдентификаторыОбъектовМетаданных.ПолноеИмяФормы = &ПолноеИмяМетаданных
	|	И ИнструментыСистемы.ЕстьСчетчик";

	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ПолноеИмяМетаданных", ОбъектМетаданных.ПолноеИмя());
	
	Выборка = Запрос.Выполнить().Выбрать();

	Если Выборка.Следующий() Тогда
		Результат = XMLСтрока(Выборка.Ссылка);
	КонецЕсли;

	Возврат Результат;
	
КонецФункции

Функция ПолучитьОсновнойИнструмент(Знач Пользователь) Экспорт
	
	ОсновнойИнструмент = Справочники.ИнструментыСистемы.ПолучитьОсновнойИнструмент(Пользователь);
	
	Если НЕ ЗначениеЗаполнено(ОсновнойИнструмент) Тогда
		Справочники.ИнструментыСистемы.ЗаполнитьНастройкиПользователяПоУмолчанию(Пользователь);
		ОсновнойИнструмент = Справочники.ИнструментыСистемы.ПолучитьОсновнойИнструмент(Пользователь);
	КонецЕсли;
	
	Возврат ОсновнойИнструмент;
	
КонецФункции

Функция ПроверитьДоступность(ДанныеИнструмента, ЭтоАдминистратор, ТекущийПользователь, ОбъектМетаданных = Неопределено) Экспорт
	
	Доступность = Истина;
	
	Если НЕ ЭтоАдминистратор Тогда
		Если ОбъектМетаданных <> Неопределено Тогда
			Доступность = ПравоДоступа("Просмотр", ОбъектМетаданных);
		КонецЕсли;
		
		Если Доступность И ЗначениеЗаполнено(ДанныеИнструмента.МетодОпределенияДоступности) Тогда
			ШаблонМетода = СтрШаблон("Доступность = %1(ТекущийПользователь)", ДанныеИнструмента.МетодОпределенияДоступности);
			
			Попытка
				Выполнить(ШаблонМетода);
			Исключение
				Доступность = Ложь;
				ТекстОшибки = СтрШаблон("%1. %2", ДанныеИнструмента.МетодОпределенияДоступности, ОписаниеОшибки());
				ЗаписьЖурналаРегистрации("Инструменты.Проверка доступности", УровеньЖурналаРегистрации.Ошибка, ,
				ДанныеИнструмента.Ссылка, ТекстОшибки);
			КонецПопытки;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Доступность;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ДоступностьГабаритноеПланирование(Знач ТекущийПользователь)
	
	Возврат Справочники.Филиалы.ИспользуетсяГабаритноеПланирование(ПараметрыСеанса.Филиал);
	
КонецФункции

Функция ДоступностьГрупповоеВнесениеТрудозатрат(Знач ТекущийПользователь)
	
	Возврат БезопасностьПереопределяемый.ПравоИспользованияГрупповогоВнесенияТрудозатрат();
	
КонецФункции

Функция ДоступностьКастомныеКоманды(Знач ТекущийПользователь)
	
	Возврат Безопасность.НаходитсяВГруппеДоступа(Справочники.ГруппыДоступа.СТОиРуководителиITНаправлений,
		ТекущийПользователь);
	
КонецФункции

Функция ДоступностьМойПрофиль(Знач ТекущийПользователь)
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	ПрофилиРазработчиков.Ссылка КАК Профиль
	|ИЗ
	|	Справочник.ПрофилиРазработчиков КАК ПрофилиРазработчиков
	|ГДЕ
	|	ПрофилиРазработчиков.Владелец = &Владелец
	|	И НЕ ПрофилиРазработчиков.ПометкаУдаления";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Владелец", ТекущийПользователь);
	Результат = НЕ Запрос.Выполнить().Пустой();
	
	Возврат Результат;
	
КонецФункции

Функция ДоступностьНастройкиФилиалов(Знач ТекущийПользователь)
	
	Результат = Истина;
	
	Если НЕ РольДоступна(Метаданные.Роли.РуководительНаправления) Тогда
		ТекстЗапроса =
		"ВЫБРАТЬ
		|	Филиалы.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Филиалы КАК Филиалы
		|ГДЕ
		|	Филиалы.Родитель = ЗНАЧЕНИЕ(Справочник.Филиалы.ПустаяСсылка)
		|	И (Филиалы.Руководитель = &Пользователь
		|			ИЛИ Филиалы.ЗаместительРуководителя = &Пользователь)";
		
		Запрос = Новый Запрос(ТекстЗапроса);
		Запрос.УстановитьПараметр("Пользователь", ТекущийПользователь);
		
		Результат = НЕ Запрос.Выполнить().Пустой();
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ДоступностьНастройкиJira(Знач ТекущийПользователь)
	
	Возврат РольДоступна(Метаданные.Роли.УправлениеНастройкамиИнтеграцииJira);
	
КонецФункции

Функция ДоступностьПрофилиСотрудников(Знач ТекущийПользователь)
	
	Возврат БезопасностьПереопределяемый.ПравоИспользованиеПрофиляРазработчика(Неопределено);
	
КонецФункции

Функция ДоступностьУправлениеУслугами(Знач ТекущийПользователь)
	
	Возврат Ложь;
	
КонецФункции

Процедура ОбработатьПодстрокиДерева(Результат, Строки, КолонкиИнструмента)
	
	Если Строки.Количество() > 0 Тогда
		Результат.Вставить("ПодчиненныеСтроки", Новый Массив);
		
		Для Каждого Строка Из Строки Цикл
			ДанныеСтроки = Новый Структура;
			
			Для Каждого Колонка Из КолонкиИнструмента Цикл
				ЗначениеСвойства = Строка[Колонка];
				
				Если ЗначениеЗаполнено(ЗначениеСвойства) Тогда
					ДанныеСтроки.Вставить(Колонка, ЗначениеСвойства);
				КонецЕсли;
			КонецЦикла;
			
			ОбработатьПодстрокиДерева(ДанныеСтроки, Строка.Строки, КолонкиИнструмента);
			
			Результат.ПодчиненныеСтроки.Добавить(ДанныеСтроки);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Функция ДоступностьУправленияЦелями(Знач ТекущийПользователь)
	
	Возврат РольДоступна(Метаданные.Роли.УправлениеЦелямиOKR);
	
КонецФункции

#КонецОбласти

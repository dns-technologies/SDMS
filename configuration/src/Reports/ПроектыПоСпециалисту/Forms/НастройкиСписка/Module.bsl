///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем УсловныеОформления; // Хранит соответствие роли участника идентификатору условного оформления

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	РегистрыСведений.ОтслеживаниеИспользованияФункциональности.ОткрытиеФормы(ЭтотОбъект.ИмяФормы);
	
	ЗаполнитьНастройкиУчастия(Параметры.НастройкиУчастия, Параметры.ПодсветкаРолей);
	
	УсловныеОформления = ДобавитьУсловноеОформлениеУчастия();
	АдресХранилища = ПоместитьВоВременноеХранилище(УсловныеОформления, УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	УсловныеОформления = ПолучитьИзВременногоХранилища(АдресХранилища);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура УчастиеЦветПодсветкиПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.Участие.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИдентификаторОформления = УсловныеОформления.Получить(ТекущиеДанные.Значение);
	ИзменитьУсловноеОформление(ИдентификаторОформления, ТекущиеДанные.ЦветПодсветки);
	
КонецПроцедуры

&НаКлиенте
Процедура УчастиеЦветПодсветкиОчистка(Элемент, СтандартнаяОбработка)
	
	ТекущиеДанные = Элементы.Участие.ТекущиеДанные;
	
	Если ТекущиеДанные <> Неопределено Тогда
		СтандартнаяОбработка = Ложь;
		ТекущиеДанные.ЦветПодсветки = Новый Цвет(255, 255, 255);
		
		ИдентификаторОформления = УсловныеОформления.Получить(ТекущиеДанные.Значение);
		ИзменитьУсловноеОформление(ИдентификаторОформления, ТекущиеДанные.ЦветПодсветки);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКоманд

&НаКлиенте
Процедура ПометитьВсе(Команда)
	
	Для Каждого Строка Из Участие Цикл
		Строка.Пометка = Истина;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура СнятьВсе(Команда)
	
	Для Каждого Строка Из Участие Цикл
		Строка.Пометка = Ложь;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура Сохранить(Команда)
	
	ВыбранныеРоли = ПолучитьВыбранные(Участие, Истина);
	ПодсветкаРолей = ПолучитьЦветаПодсветки();
	
	НастройкиСписка = Новый Структура;  
	НастройкиСписка.Вставить("НастройкиУчастия", ВыбранныеРоли);
	НастройкиСписка.Вставить("ПодсветкаРолей", ПодсветкаРолей);
	
	Закрыть(НастройкиСписка);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьНастройкиПодсветкиПоУмолчанию(Команда)
	
	УстановитьНастройкиПодсветкиПоУмолчаниюНаСервере(УсловныеОформления);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ДобавитьУсловноеОформлениеУчастия()
	
	УсловныеОформления = Новый Соответствие;
	
	Для Каждого Строка Из Участие Цикл
		ЭлементУсловноеОформление = УсловноеОформление.Элементы.Добавить();
		
		ГруппаОтбора = ЭлементУсловноеОформление.Отбор.Элементы.Добавить(Тип("ГруппаЭлементовОтбораКомпоновкиДанных"));
		ГруппаОтбора.Использование = Истина;
		ГруппаОтбора.ТипГруппы = ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИ;
		
		ЭлементОтбора = ГруппаОтбора.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Участие.ЦветПодсветки");
		ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Заполнено;
		ЭлементОтбора.Использование = Истина;
		
		ЭлементОтбора = ГруппаОтбора.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Участие.Значение");
		ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
		ЭлементОтбора.ПравоеЗначение = Строка.Значение;
		ЭлементОтбора.Использование = Истина;
		
		Элемент = ЭлементУсловноеОформление.Поля.Элементы.Добавить();
		Элемент.Поле = Новый ПолеКомпоновкиДанных("УчастиеЦветПодсветки");
		Элемент.Использование = Истина;
		
		ЭлементОформления = ЭлементУсловноеОформление.Оформление.НайтиЗначениеПараметра(
			Новый ПараметрКомпоновкиДанных("ЦветФона"));
		ЭлементОформления.Значение = Строка.ЦветПодсветки;
		ЭлементОформления.Использование = Истина;
		
		Идентификатор = УсловноеОформление.ПолучитьИдентификаторПоОбъекту(ЭлементУсловноеОформление);
		УсловныеОформления.Вставить(Строка.Значение, Идентификатор);
	КонецЦикла; 
	
	Возврат УсловныеОформления;
	
КонецФункции

&НаСервере
Процедура ЗаполнитьНастройкиУчастия(НастройкиУчастия, ПодсветкаРолей)
	
	Для Каждого ЭлементСписка Из НастройкиУчастия Цикл
		НоваяСтрока = Участие.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, ЭлементСписка);
		НоваяСтрока.ЦветПодсветки = ПодсветкаРолей.Получить(ЭлементСписка.Значение);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ИзменитьУсловноеОформление(Знач ИдентификаторОформления, Знач ЦветПодсветки)
	
	ЭлементОформления = УсловноеОформление.ПолучитьОбъектПоИдентификатору(ИдентификаторОформления);
	ЭлементЦветФона = ЭлементОформления.Оформление.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ЦветФона"));
	ЭлементЦветФона.Значение = ЦветПодсветки;
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьВыбранные(Список, Знач ПолучитьСписок = Ложь)
	
	Если ПолучитьСписок Тогда
		ВыбранныеЗначения = Новый СписокЗначений;
	Иначе
		ВыбранныеЗначения = Новый Массив;
	КонецЕсли; 
	
	Для Каждого Строка Из Список Цикл
		Если ПолучитьСписок Тогда
			ЗаполнитьЗначенияСвойств(ВыбранныеЗначения.Добавить(), Строка);
		ИначеЕсли Строка.Пометка Тогда
			ВыбранныеЗначения.Добавить(Строка.Значение);
		КонецЕсли;
	КонецЦикла; 
	
	Возврат ВыбранныеЗначения;
	
КонецФункции

&НаКлиенте
Функция ПолучитьЦветаПодсветки()
	
	ЦветаПодсветки = Новый Соответствие;
	
	Для Каждого Строка Из Участие Цикл
		ЦветаПодсветки.Вставить(Строка.Значение, Строка.ЦветПодсветки);
	КонецЦикла; 
	
	Возврат ЦветаПодсветки;
	
КонецФункции

&НаСервере
Процедура УстановитьНастройкиПодсветкиПоУмолчаниюНаСервере(Знач УсловныеОформления)
	
	Участие.Очистить();
	
	ПодсветкаПоУмолчанию = Новый Соответствие;
	ПодсветкаПоУмолчанию.Вставить(Справочники.РолиУчастников.УчастникКомандыУправленияПроектом,
		ЦветаСтиля.ЦветГруппировочнойСтрокиТаблицы);
	ПодсветкаПоУмолчанию.Вставить(Справочники.РолиУчастников.Автор, WebЦвета.БледноЛиловый);
	ПодсветкаПоУмолчанию.Вставить(Справочники.РолиУчастников.Заказчик, WebЦвета.БледноЛиловый);
	ПодсветкаПоУмолчанию.Вставить(Справочники.РолиУчастников.Наблюдатель, WebЦвета.БледноЛиловый);
	ПодсветкаПоУмолчанию.Вставить(Справочники.РолиУчастников.РуководительПроекта, Новый Цвет(255, 255, 255));
	ПодсветкаПоУмолчанию.Вставить(Справочники.РолиУчастников.Исполнитель, Новый Цвет(255, 255, 255));
	
	НастройкиУчастияПоУмолчанию = Новый СписокЗначений;
	НастройкиУчастияПоУмолчанию.Добавить(Справочники.РолиУчастников.РуководительПроекта, "Руководитель проекта", Истина);
	НастройкиУчастияПоУмолчанию.Добавить(Справочники.РолиУчастников.Исполнитель, "Исполнитель", Истина);
	НастройкиУчастияПоУмолчанию.Добавить(Справочники.РолиУчастников.УчастникКомандыУправленияПроектом,
		"Участник команды управления проектом", Истина);
	НастройкиУчастияПоУмолчанию.Добавить(Справочники.РолиУчастников.Заказчик, "Заказчик");
	НастройкиУчастияПоУмолчанию.Добавить(Справочники.РолиУчастников.Наблюдатель, "Наблюдатель");
	НастройкиУчастияПоУмолчанию.Добавить(Справочники.РолиУчастников.Автор, "Автор");
	
	Для Каждого Строка Из НастройкиУчастияПоУмолчанию Цикл
		НоваяСтрока = Участие.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
		НоваяСтрока.ЦветПодсветки = ПодсветкаПоУмолчанию.Получить(Строка.Значение);
		
		ИдентификаторОформления = УсловныеОформления.Получить(Строка.Значение);
		ИзменитьУсловноеОформление(ИдентификаторОформления, НоваяСтрока.ЦветПодсветки);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

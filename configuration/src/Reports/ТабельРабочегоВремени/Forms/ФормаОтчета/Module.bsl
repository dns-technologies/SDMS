///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ТекущаяДата = ТекущаяДатаСеанса();
	ПериодВыборМесяца = НачалоМесяца(ТекущаяДата);
		
	ПроизвестиЗаполнениеТаблицыЦветов();	
	ЗаполнитьСписокМесяцев(ПериодВыборМесяца, Элементы.ПериодВыборМесяца.СписокВыбора);
	ЗагрузитьПользовательскиеНастройки();
			
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ПериодВыборМесяцаОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ОбработатьИзменениеМесяца(ВыбранноеЗначение);
	
КонецПроцедуры

&НаКлиенте
Процедура РезультатОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка, ДополнительныеПараметры)
	
	СтандартнаяОбработка = Ложь;		
	
	ФилиалыДляРасшифровки = Новый СписокЗначений;

	ПараметрыРасшифровки = ПолучитьФилиалИзРасшифровки(АдресДанныеРасшифровки, Расшифровка);
	
	Если НЕ ПараметрыРасшифровки.Свойство("Филиал") Тогда
		Возврат;		
	КонецЕсли;

	Если ЗначениеЗаполнено(ПараметрыРасшифровки.Филиал) Тогда		
		ФилиалыДляРасшифровки.Добавить(ПараметрыРасшифровки.Филиал);
	ИначеЕсли ОтборФилиал Тогда
		ФилиалыДляРасшифровки = Филиалы;
	КонецЕсли;
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("Филиалы", ФилиалыДляРасшифровки);	
	ПараметрыОткрытия.Вставить("ДатаНачала", ПериодВыборМесяца);
		
	ОткрытьФорму("Отчет.ТабельРабочегоВремени.Форма.ФормаРасшифровки", ПараметрыОткрытия, ЭтотОбъект, 
		Новый УникальныйИдентификатор, , , , РежимОткрытияОкнаФормы.Независимый);
		
КонецПроцедуры

&НаКлиенте
Процедура СгруппироватьПоТерриторииПриИзменении(Элемент)
	
	Если СгруппироватьПоТерритории Тогда
		КлючТекущегоВарианта = "ГруппировкаПоТерритории";
	Иначе
		КлючТекущегоВарианта = "Основной";
	КонецЕсли;
	
	КлючОбъекта = СтрШаблон("Отчет.ТабельРабочегоВремени/%1/ТекущиеПользовательскиеНастройки", КлючТекущегоВарианта);
	
	ЭтотОбъект.УстановитьТекущийВариант(КлючТекущегоВарианта);
	
	СохраненныеНастройки = ОбщегоНазначенияВызовСервера.ЗагрузитьСистемнуюНастройку(КлючОбъекта,);
	
	Если СохраненныеНастройки <> Неопределено Тогда
		Отчет.КомпоновщикНастроек.ЗагрузитьПользовательскиеНастройки(СохраненныеНастройки);
	КонецЕсли;
	
	// Текстовая подсказка состояния отчета.
	ОтобразитьСостояниеОтчета(НСтр("ru = 'Выбран другой вариант отчета. Нажмите ""Сформировать"" для получения отчета.'"),
		БиблиотекаКартинок.Информация32);

КонецПроцедуры
	
#КонецОбласти

#Область ОбработчикиКоманд

&НаКлиенте
Процедура СформироватьОтчет(Команда)
	
	СформироватьОтчетНаСервере();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗагрузитьПользовательскиеНастройки()
	
	Ключи = ПолучитьКлючиНастроек();
	Настройки = ОбщегоНазначенияВызовСервера.ЗагрузитьНастройкиДанныхФормы(Ключи.Объект, Ключи.Настройка);
	
	Если Настройки <> Неопределено Тогда
		Настройки.Свойство("ПериодВыборМесяца", ПериодВыборМесяца);
		Настройки.Свойство("ОтборФилиал", ОтборФилиал);
		Настройки.Свойство("Филиалы", Филиалы);
		Настройки.Свойство("СгруппироватьПоТерритории", СгруппироватьПоТерритории);
	КонецЕсли;
	
	Если СгруппироватьПоТерритории Тогда
		КлючОбъекта = "Отчет.ТабельРабочегоВремени/ГруппировкаПоТерритории/ТекущиеПользовательскиеНастройки";
	КонецЕсли;	
	
	СохраненныеНастройки = ОбщегоНазначенияВызовСервера.ЗагрузитьСистемнуюНастройку(КлючОбъекта,);
		
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьСписокМесяцев(Знач Период, СписокЗначений)
	
	ГодПериода = Год(Период);
	ТекущаяДата = ОбщегоНазначенияВызовСервера.ТекущаяДатаСеансаНаСервере();
	
	// Если это текущий год, то нужно ограничить период текущим месяцем, т.к. будущими
	// месяцами еще данных нету.
	Если Год(ТекущаяДата) = ГодПериода Тогда
		МаксимальныйМесяц = Месяц(ТекущаяДата);
	Иначе
		МаксимальныйМесяц = 12;
	КонецЕсли;
	
	СписокЗначений.Очистить();
	
	ПредыдущийГод = ГодПериода - 1;
	СписокЗначений.Добавить(Дата(ПредыдущийГод, 12, 1), "Предыдущий год (" + Формат(ПредыдущийГод, "ЧГ=") + ")");
	
	Для Месяц = 1 По МаксимальныйМесяц Цикл
		Дата = Дата(ГодПериода, Месяц, 1);
		ПредставлениеДаты = Формат(Дата, "ДФ='MMMM yyyy'");
		
		СписокЗначений.Добавить(Дата, ПредставлениеДаты);
	КонецЦикла;
	
	// Если это текущий год, то нету смысла давать пользоватею возможность переходить
	// в будущие года.
	Если МаксимальныйМесяц = 12 Тогда
		СледующийГод = ГодПериода + 1;
		СписокЗначений.Добавить(Дата(СледующийГод, 1, 1), "Следующий год (" + Формат(СледующийГод, "ЧГ=") + ")");	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьИзменениеМесяца(ВыбранноеЗначение)
	
	Если Год(ПериодВыборМесяца) <> Год(ВыбранноеЗначение) Тогда
		ЗаполнитьСписокМесяцев(ВыбранноеЗначение, Элементы.ПериодВыборМесяца.СписокВыбора);
	КонецЕсли;
	
	ПериодВыборМесяца = ВыбранноеЗначение;
	
КонецПроцедуры

&НаСервере
Процедура ОтобразитьСостояниеОтчета(Знач ТекстСостояния = "", Знач КартинкаСостояния = Неопределено)
	
	ОтображатьСостояние = НЕ ПустаяСтрока(ТекстСостояния);
	Если КартинкаСостояния = Неопределено 
		ИЛИ НЕ ОтображатьСостояние Тогда 

		КартинкаСостояния = Новый Картинка;
	КонецЕсли;
	
	ОтображениеСостояния = Элементы.Результат.ОтображениеСостояния;
	ОтображениеСостояния.Видимость = ОтображатьСостояние;
	ОтображениеСостояния.Картинка = КартинкаСостояния;
	ОтображениеСостояния.Текст = ТекстСостояния;
	ОтображениеСостояния.ДополнительныйРежимОтображения = ?(ОтображатьСостояние, 
		ДополнительныйРежимОтображения.Неактуальность, ДополнительныйРежимОтображения.НеИспользовать);
	
	Элементы.Результат.ТолькоПросмотр = (ОтображатьСостояние 
										ИЛИ (Элементы.Результат.Вывод = ИспользованиеВывода.Запретить));
		
КонецПроцедуры

&НаСервере
Функция ПолучитьКлючиНастроек()
	
	Возврат Новый Структура("Объект, Настройка", "Отчет.ТабельРабочегоВремени", "ПользовательскиеНастройки");
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьФилиалИзРасшифровки(Знач АдресДанныеРасшифровки, Знач ИдентификаторРасшифровки)
	
	ФилиалСсылка = Справочники.Филиалы.ПустаяСсылка();
	
	ДанныеРасшифровки = ПолучитьИзВременногоХранилища(АдресДанныеРасшифровки);
	СтрокаРасшифровки = ДанныеРасшифровки.Элементы[ИдентификаторРасшифровки];

	СтруктураРасшифровки = Новый Структура;
	
	Родители = СтрокаРасшифровки.ПолучитьРодителей();
	Для Каждого Родитель из Родители Цикл
		Если ТипЗнч(Родитель) = Тип("ЭлементРасшифровкиКомпоновкиДанныхПоля") Тогда
			Поля = Родитель.ПолучитьПоля();
			Для Каждого Поле из Поля Цикл
				Если Не Поле.Иерархия  Тогда
					СтруктураРасшифровки.Вставить(Поле.Поле, Поле.Значение);
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
	Возврат СтруктураРасшифровки;
	
КонецФункции

&НаКлиенте
Процедура ПослеВыбораФилиалов(Знач ВыбранныеФилиалы, Знач ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФилиалы <> Неопределено Тогда
		Филиалы = ВыбранныеФилиалы;
	КонецЕсли;

	ОтборФилиал = (Филиалы.Количество() > 0);
	
КонецПроцедуры

&НаСервере
Процедура СохранитьПользовательскиеНастройки()
	
	Ключи = ПолучитьКлючиНастроек();
	ПользовательскиеНастройкиОтчета = СформироватьПользовательскиеНастройки();
	
	ОбщегоНазначенияВызовСервера.СохранитьНастройкиДанныхФормы(Ключи.Объект, Ключи.Настройка, 
		ПользовательскиеНастройкиОтчета);		
		
	ПользовательскиеНастройки = Отчет.КомпоновщикНастроек.ПользовательскиеНастройки;
	КлючОбъекта = СтрШаблон("Отчет.ТабельРабочегоВремени/%1/ТекущиеПользовательскиеНастройки", КлючТекущегоВарианта);
	ОбщегоНазначенияВызовСервера.СохранитьСистемнуюНастройку(КлючОбъекта,, ПользовательскиеНастройки);	
	
КонецПроцедуры

&НаСервере
Процедура СформироватьОтчетНаСервере()
	
	Результат.Очистить();
	
	// Определяем дату окончания для построения отчета.
	// Для текущего месяца, это будет -1 день от текущей даты.
	ТекущаяДата = ТекущаяДатаСеанса();
	ТекущееНачалоМесяца = НачалоМесяца(ТекущаяДата);
	
	Если ПериодВыборМесяца = ТекущееНачалоМесяца Тогда 	
		ДатаОкончания = НачалоДня(ТекущаяДата) - 86400;
		ДатаОкончанияТрудозатрат = НачалоДня(ТекущаяДата); // Да, у нас 2 даты окончания. Все нормально.
	Иначе
		ДатаОкончания = КонецМесяца(ПериодВыборМесяца);
		ДатаОкончанияТрудозатрат = КонецМесяца(ПериодВыборМесяца);
	КонецЕсли;

	ОтчетОбъект = РеквизитФормыВЗначение("Отчет");
	СхемаКомпоновкиДанных = ОтчетОбъект.СхемаКомпоновкиДанных;	
		
	ПользовательскиеНастройки = Отчет.КомпоновщикНастроек.ПользовательскиеНастройки;
	УстановитьУсловноеОформлениеДляКомпоновщика("ПроцентЗанесения");
			
	// Настройки (с наложением пользовательских).
	НастройкиСКД = Отчет.КомпоновщикНастроек.ПолучитьНастройки();
			
	// Параметры
	ПараметрДатаНачала = НастройкиСКД.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ДатаНачала"));	
	ПараметрДатаНачала.Значение = ПериодВыборМесяца;
	
	ПараметрДатаКонец = НастройкиСКД.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ДатаОкончания"));	
	ПараметрДатаКонец.Значение = ДатаОкончания;
	
	ПараметрДатаКонецТрудозатрат = НастройкиСКД.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ДатаОкончанияТрудозатрат"));	
	ПараметрДатаКонецТрудозатрат.Значение = ДатаОкончанияТрудозатрат;
	
	Отбор = НастройкиСКД.Отбор.Элементы.Получить(0);
	Отбор.ПравоеЗначение = Филиалы;
	Отбор.Использование = ОтборФилиал;
		
	ДанныеРасшифровкиКомпоновкиДанных = Новый ДанныеРасшифровкиКомпоновкиДанных;

	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, НастройкиСКД, ДанныеРасшифровкиКомпоновкиДанных);
	
	// ВнешниеНаборыДанных
	ТаблицаОтсутствий = Отчеты.ТабельРабочегоВремени.ПолучитьТаблицуОтсутствий(ПериодВыборМесяца);
			
	ВнешниеНаборыДанных = Новый Структура;
	ВнешниеНаборыДанных.Вставить("ДатыОтсутствияСотрудников", ТаблицаОтсутствий); 	
	
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновки, ВнешниеНаборыДанных, ДанныеРасшифровкиКомпоновкиДанных, Истина);
		
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(Результат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);	
		
	// Данные расшифровки
	АдресДанныеРасшифровки = ПоместитьВоВременноеХранилище(ДанныеРасшифровкиКомпоновкиДанных, ЭтотОбъект.УникальныйИдентификатор);
	
	// Убираем дополнительную информацию.
	ОтобразитьСостояниеОтчета();
	
	// Сохранение настроек отчета
	СохранитьПользовательскиеНастройки();
		
КонецПроцедуры   

&НаСервере
Функция СформироватьПользовательскиеНастройки()
	
	ПользовательскиеНастройки = Новый Структура;
	
	ПользовательскиеНастройки.Вставить("ПериодВыборМесяца", ПериодВыборМесяца);
	ПользовательскиеНастройки.Вставить("ОтборФилиал", ОтборФилиал);
	ПользовательскиеНастройки.Вставить("Филиалы", Филиалы);
	ПользовательскиеНастройки.Вставить("СгруппироватьПоТерритории", СгруппироватьПоТерритории);
	
	Возврат ПользовательскиеНастройки;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Условное оформление

&НаСервере
Процедура ДобавитьЭлементОтбораКомпоновкиДанных(НастройкиСКД, Знач ИмяПоля, Знач ВидСравнения, Знач Значение) Экспорт
	
	НовыйЭлементОтбора = НастройкиСКД.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	НовыйЭлементОтбора.ВидСравнения = ВидСравнения;
	НовыйЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ИмяПоля);
	НовыйЭлементОтбора.ПравоеЗначение = Значение;
	НовыйЭлементОтбора.Использование = Истина;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСтруктуруНастроекОформления(НастройкиОформления, Знач НачальноеЗначение, Знач КонечноеЗначение, Знач НачальныйЦвет, Знач КонечныйЦвет)
	
	НастройкиОформления.НачальноеЗначение = НачальноеЗначение; 
	НастройкиОформления.КонечноеЗначение = КонечноеЗначение;
	НастройкиОформления.НачальныйЦвет = НачальныйЦвет;
	НастройкиОформления.КонечныйЦвет = КонечныйЦвет;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьСтруктуруНастроекОформления()
	
	НастройкиОформления = Новый Структура;
	НастройкиОформления.Вставить("НачальноеЗначение", 0); 
	НастройкиОформления.Вставить("КонечноеЗначение", 0);
	НастройкиОформления.Вставить("НачальныйЦвет", Новый Цвет(0, 0, 0));
	НастройкиОформления.Вставить("КонечныйЦвет", Новый Цвет(0, 0, 0));
	
	Возврат НастройкиОформления;
	
КонецФункции

&НаСервере
Процедура ПроизвестиЗаполнениеТаблицыЦветов()
			
	НастройкиОформления = ПолучитьСтруктуруНастроекОформления();
	
	// Первая группа.
	ЗаполнитьСтруктуруНастроекОформления(НастройкиОформления, 0.1, 50, Новый Цвет(255, 210, 210), Новый Цвет(255, 230, 210));	
	ПроизвестиЗаполнениеГруппыОформленияДляТаблицыЦветов(НастройкиОформления, 5);
	
	// Вторая группа.
	ЗаполнитьСтруктуруНастроекОформления(НастройкиОформления, 50, 70, Новый Цвет(255, 230, 210), Новый Цвет(255, 255, 210));		
	ПроизвестиЗаполнениеГруппыОформленияДляТаблицыЦветов(НастройкиОформления, 4);
	
	// Третья группа.
	ЗаполнитьСтруктуруНастроекОформления(НастройкиОформления, 70, 84, Новый Цвет(255, 255, 210), Новый Цвет(230, 255, 210));		
	ПроизвестиЗаполнениеГруппыОформленияДляТаблицыЦветов(НастройкиОформления, 4);
	
	// Четвертая группа.
	ЗаполнитьСтруктуруНастроекОформления(НастройкиОформления, 84, 100, Новый Цвет(210, 240, 210), Новый Цвет(200, 255, 210));		
	ПроизвестиЗаполнениеГруппыОформленияДляТаблицыЦветов(НастройкиОформления, 4);
	
КонецПроцедуры

&НаСервере
Процедура ПроизвестиЗаполнениеГруппыОформленияДляТаблицыЦветов(Знач НастройкиОформления, Знач КоличествоРазбиений)
	
	НачальноеЗначение = НастройкиОформления.НачальноеЗначение;
	КонечноеЗначение = НастройкиОформления.КонечноеЗначение; 
	НачальныйЦвет = НастройкиОформления.НачальныйЦвет;
	КонечныйЦвет = НастройкиОформления.КонечныйЦвет;
	
	ДельтаКрасный = КонечныйЦвет.Красный - НачальныйЦвет.Красный;
	ДельтаЗеленый = КонечныйЦвет.Зеленый - НачальныйЦвет.Зеленый;
	НеобходимоеКоличествоРазбиений = Макс(КоличествоРазбиений - 1, 1);
	СмещениеЦветаКрасный = Окр(ДельтаКрасный / НеобходимоеКоличествоРазбиений, 1);
	СмещениеЦветаЗеленый = Окр(ДельтаЗеленый / НеобходимоеКоличествоРазбиений, 1);
	КоэффициентИзмененияЗначения = Окр((КонечноеЗначение - НачальноеЗначение) / КоличествоРазбиений, 1);
	
	Счетчик = 0;
	Пока Счетчик < КоличествоРазбиений Цикл	
		СтрокаЦвета = ТаблицаРаспределенияЦветов.Добавить();
		СтрокаЦвета.НачальноеЗначение = НачальноеЗначение + Окр(КоэффициентИзмененияЗначения * Счетчик, 0);
		СтрокаЦвета.КонечноеЗначение = Мин(НачальноеЗначение + Окр(КоэффициентИзмененияЗначения * (Счетчик + 1), 0), КонечноеЗначение);
		
		Красный = НачальныйЦвет.Красный + Окр(СмещениеЦветаКрасный * Счетчик, 0); 
		Зеленый = НачальныйЦвет.Зеленый + Окр(СмещениеЦветаЗеленый * Счетчик, 0); 
		Синий = 210;
				
		СтрокаЦвета.Цвет = Новый Цвет(Красный, Зеленый, Синий);
		Счетчик = Счетчик + 1;		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформлениеДляКомпоновщика(Знач ОформляемоеПоле) 
	
	Если СгруппироватьПоТерритории Тогда
		ЭлементУсловноеОформление = Отчет.КомпоновщикНастроек.Настройки.Структура[0].Структура[0].УсловноеОформление;
	Иначе     
		ЭлементУсловноеОформление = Отчет.КомпоновщикНастроек.Настройки.Структура[0].УсловноеОформление;
	КонецЕсли;
	
	ЭлементУсловноеОформление.Элементы.Очистить();
	
	Для Каждого СтрокаТаблицы Из ТаблицаРаспределенияЦветов Цикл	
		НовоеУсловноеОформление = ЭлементУсловноеОформление.Элементы.Добавить();	
		НовоеУсловноеОформление.Использование = Истина;
		НовоеУсловноеОформление.ИспользоватьВОбщемИтоге = ИспользованиеУсловногоОформленияКомпоновкиДанных.НеИспользовать;
		НовоеУсловноеОформление.ИспользоватьВЗаголовкеПолей = ИспользованиеУсловногоОформленияКомпоновкиДанных.НеИспользовать;
		
		// Устанавливаем границы значений для оформления.
		ДобавитьЭлементОтбораКомпоновкиДанных(НовоеУсловноеОформление, ОформляемоеПоле, ВидСравненияКомпоновкиДанных.БольшеИлиРавно,
			СтрокаТаблицы.НачальноеЗначение);
			
		Если ЗначениеЗаполнено(СтрокаТаблицы.КонечноеЗначение) Тогда	
			ДобавитьЭлементОтбораКомпоновкиДанных(НовоеУсловноеОформление, ОформляемоеПоле, ВидСравненияКомпоновкиДанных.Меньше,
				СтрокаТаблицы.КонечноеЗначение);
		КонецЕсли;
		
		НовоеПолеДляОформления = НовоеУсловноеОформление.Поля.Элементы.Добавить();		
		НовоеПолеДляОформления.Поле = Новый ПолеКомпоновкиДанных(ОформляемоеПоле);
		НовоеПолеДляОформления.Использование = Истина;
		
		ЭлементОформления = НовоеУсловноеОформление.Оформление.Элементы.найти("BackColor");
		ЭлементОформления.Значение = СтрокаТаблицы.Цвет;
		ЭлементОформления.Использование = Истина;
	КонецЦикла;
		
КонецПроцедуры

&НаКлиенте
Процедура ФилиалыНачалоВыбора(Элемент, ДанныеВыбора, ВыборДобавлением, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПослеВыбораФилиалов", ЭтотОбъект);
			
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("ТолькоИТФилиалы", Истина);
	ПараметрыОткрытия.Вставить("ВыбранныеФилиалы", Филиалы);

	ОткрытьФорму("Справочник.Филиалы.Форма.МножественныйВыбор", ПараметрыОткрытия, ЭтотОбъект, ЭтотОбъект.УникальныйИдентификатор,,, ОписаниеОповещения,
		РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

#КонецОбласти      

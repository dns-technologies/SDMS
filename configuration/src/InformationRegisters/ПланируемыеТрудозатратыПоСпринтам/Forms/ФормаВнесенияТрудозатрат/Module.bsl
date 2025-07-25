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
	
	МассивТрудозатрат = Новый Массив;	
	Параметры.Свойство("Объект", Объект); 
	Параметры.Свойство("Спринты", ВыбранныеСпринты);
	
	Если Параметры.Свойство("ТипТрудозатрат") Тогда
		ТипТрудозатрат = Параметры.ТипТрудозатрат;	
	Иначе
		ТипТрудозатрат = Перечисления.ТипыТрудозатрат.Разработка;
	КонецЕсли;
	
	ОткрытиеИзФормыЗадачи = Параметры.Свойство("ОткрытиеИзФормыЗадачи") И Параметры.ОткрытиеИзФормыЗадачи;
	ПолучитьПлановыеТрудозатраты = Параметры.ПолучитьПлановыеТрудозатраты;
	
	Элементы.ЗакрытьФорму.Видимость = НЕ ПолучитьПлановыеТрудозатраты; 
	Элементы.Сохранить.Видимость = ПолучитьПлановыеТрудозатраты;
	
	НастроитьВидимостьКолонокТрудозатрат(ТипТрудозатрат, ПолучитьПлановыеТрудозатраты, ОткрытиеИзФормыЗадачи);
	
	ПолучитьТрудозатраты(ПолучитьПлановыеТрудозатраты);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗакрытьФорму(Команда)

	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура Сохранить(Команда)
		
	Если РедактированиеПлановыхТрудозатратНаРазработку Тогда 
		Незаполненные = ТаблицаСпринтов.НайтиСтроки(Новый Структура("Пометка, Трудозатраты", Истина, 0));    
		
		Если Незаполненные.Количество() > 0 Тогда 
			Для Каждого Строка Из Незаполненные Цикл  
				Текст = СтрШаблон("Для %1 требуется указать примерное время выполнения", Строка(Строка.Спринт));
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Текст);
			КонецЦикла;	                              
			
			Возврат;
		КонецЕсли; 
	КонецЕсли;
	
	СохранитьТрудозатраты();
	
	// После закрытия этой формы нужно обновить общие плановые трудозатраты на форме документа, откуда они редактируются.
	Трудозатраты = ?(РедактированиеПлановыхТрудозатратНаРазработку, ТрудозатратыНачальные, ТрудозатратыНачальныеТестирование);
	Закрыть(Новый Структура("Трудозатраты", Трудозатраты));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции   

&НаСервере
Процедура НастроитьВидимостьКолонокТрудозатрат(ТипТрудозатрат, ПолучитьПлановыеТрудозатраты, ОткрытиеИзФормыЗадачи)
	
    ВидимостьКолонкиТрудозатраты = Ложь;
	ВидимостьКолонкиТрудозатратыТестирование = Ложь;
	
	Если НЕ ПолучитьПлановыеТрудозатраты Тогда
		// Для фактических трудозатрат всегда отображается и заполняется колонка "Трудозатраты"
		Заголовок = "Время фактических трудозатрат"; 
		ВидимостьКолонкиТрудозатраты = Истина;
	Иначе
		Если ОткрытиеИзФормыЗадачи Тогда 
			// Если форма открывается из задачи при выборе спринта, то отображаются и заполняются обе колонки
			ВидимостьКолонкиТрудозатраты = Истина;
			ВидимостьКолонкиТрудозатратыТестирование = Истина;
		Иначе 
			// Иначе видимость определяется по типу трудозатрат
			ВидимостьКолонкиТрудозатраты = ТипТрудозатрат = Перечисления.ТипыТрудозатрат.Разработка;
			ВидимостьКолонкиТрудозатратыТестирование = НЕ ВидимостьКолонкиТрудозатраты;
		КонецЕсли;
		
		РедактированиеПлановыхТрудозатратНаРазработку = ВидимостьКолонкиТрудозатраты;
		РедактированиеПлановыхТрудозатратНаТестирование = ВидимостьКолонкиТрудозатратыТестирование;
	КонецЕсли;
	
	Элементы.ТаблицаСпринтовТрудозатраты.Видимость = ВидимостьКолонкиТрудозатраты;
	Элементы.ТаблицаСпринтовТрудозатратыТестирование.Видимость = ВидимостьКолонкиТрудозатратыТестирование;
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьТрудозатраты(ПолучитьПлановыеТрудозатраты = Истина)
	
	Если ПолучитьПлановыеТрудозатраты Тогда
		Запрос = Новый Запрос;
		Запрос.Текст =
		#Область ТекстЗапроса
		"ВЫБРАТЬ
		|	СоставСпринтов.Спринт КАК Спринт,
		|	ЕСТЬNULL(ПланируемыеТрудозатратыПоСпринтам.Трудозатраты, 0) КАК Трудозатраты,
		|	ЕСТЬNULL(ПланируемыеТрудозатратыПоСпринтамТестирование.Трудозатраты, 0) КАК ТрудозатратыТестирование,
		|	ВЫБОР
		|		КОГДА &ТекущаяДата <= КОНЕЦПЕРИОДА(ДокументСпринт.ДатаОкончания, ДЕНЬ)
		|			ТОГДА ИСТИНА
		|		ИНАЧЕ ЛОЖЬ
		|	КОНЕЦ КАК Пометка,
		|	ЛОЖЬ КАК Добавленный,
		|	СоставСпринтов.Объект КАК Объект,
		|	ДокументСпринт.ДатаНачала КАК ДатаНачала
		|ПОМЕСТИТЬ СпринтыОбъекта
		|ИЗ
		|	РегистрСведений.СоставСпринтов КАК СоставСпринтов
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПланируемыеТрудозатратыПоСпринтам КАК ПланируемыеТрудозатратыПоСпринтам
		|		ПО СоставСпринтов.Спринт = ПланируемыеТрудозатратыПоСпринтам.Спринт
		|			И СоставСпринтов.Объект = ПланируемыеТрудозатратыПоСпринтам.Объект
		|			И (ПланируемыеТрудозатратыПоСпринтам.ТипТрудозатрат = ЗНАЧЕНИЕ(Перечисление.ТипыТрудозатрат.Разработка))
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПланируемыеТрудозатратыПоСпринтам КАК ПланируемыеТрудозатратыПоСпринтамТестирование
		|		ПО СоставСпринтов.Спринт = ПланируемыеТрудозатратыПоСпринтамТестирование.Спринт
		|			И СоставСпринтов.Объект = ПланируемыеТрудозатратыПоСпринтамТестирование.Объект
		|			И (ПланируемыеТрудозатратыПоСпринтамТестирование.ТипТрудозатрат = ЗНАЧЕНИЕ(Перечисление.ТипыТрудозатрат.Тестирование))
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Спринт КАК ДокументСпринт
		|		ПО СоставСпринтов.Спринт = ДокументСпринт.Ссылка
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ИсторияУчастияОбъектовВСпринтах.СрезПоследних КАК ИсторияУчастияОбъектовВСпринтахСрезПоследних
		|		ПО (ИсторияУчастияОбъектовВСпринтахСрезПоследних.Спринт = СоставСпринтов.Спринт)
		|			И (ИсторияУчастияОбъектовВСпринтахСрезПоследних.Объект = СоставСпринтов.Объект)
		|ГДЕ
		|	СоставСпринтов.Объект = &Объект
		|	И ВЫБОР
		|			КОГДА &ФильтрСпринты
		|				ТОГДА СоставСпринтов.Спринт В (&ВыбранныеСпринты)
		|			ИНАЧЕ ИСТИНА
		|		КОНЕЦ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СУММА(СпринтыОбъекта.Трудозатраты) КАК Трудозатраты,
		|	СУММА(СпринтыОбъекта.ТрудозатратыТестирование) КАК ТрудозатратыТестирование,
		|	СпринтыОбъекта.Объект КАК Объект
		|ПОМЕСТИТЬ РаспределенныеТрудозатраты
		|ИЗ
		|	СпринтыОбъекта КАК СпринтыОбъекта
		|
		|СГРУППИРОВАТЬ ПО
		|	СпринтыОбъекта.Объект
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ДокументСпринт.Ссылка КАК Спринт,
		|	ЕСТЬNULL(ПланируемыеТрудозатраты.Трудозатраты, 0) - ЕСТЬNULL(РаспределенныеТрудозатраты.Трудозатраты, 0) КАК Трудозатраты,
		|	ЕСТЬNULL(ПланируемыеТрудозатратыТестирование.Трудозатраты, 0) - ЕСТЬNULL(РаспределенныеТрудозатраты.ТрудозатратыТестирование, 0) КАК ТрудозатратыТестирование,
		|	ВЫБОР
		|		КОГДА &ТекущаяДата <= КОНЕЦПЕРИОДА(ДокументСпринт.ДатаОкончания, ДЕНЬ)
		|			ТОГДА ИСТИНА
		|		ИНАЧЕ ЛОЖЬ
		|	КОНЕЦ КАК Пометка,
		|	ИСТИНА КАК Добавленный,
		|	ДокументСпринт.ДатаНачала КАК ДатаНачала
		|ПОМЕСТИТЬ ДобавленныеСпринты
		|ИЗ
		|	Документ.Спринт КАК ДокументСпринт
		|		ЛЕВОЕ СОЕДИНЕНИЕ СпринтыОбъекта КАК СпринтыОбъекта
		|		ПО ДокументСпринт.Ссылка = СпринтыОбъекта.Спринт
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПланируемыеТрудозатраты КАК ПланируемыеТрудозатраты
		|		ПО (ПланируемыеТрудозатраты.Объект = &Объект)
		|			И (ПланируемыеТрудозатраты.ТипТрудозатрат = ЗНАЧЕНИЕ(Перечисление.ТипыТрудозатрат.Разработка))
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПланируемыеТрудозатраты КАК ПланируемыеТрудозатратыТестирование
		|		ПО (ПланируемыеТрудозатратыТестирование.Объект = &Объект)
		|			И (ПланируемыеТрудозатратыТестирование.ТипТрудозатрат = ЗНАЧЕНИЕ(Перечисление.ТипыТрудозатрат.Тестирование))
		|		ЛЕВОЕ СОЕДИНЕНИЕ РаспределенныеТрудозатраты КАК РаспределенныеТрудозатраты
		|		ПО (РаспределенныеТрудозатраты.Объект = &Объект)
		|ГДЕ
		|	ДокументСпринт.Ссылка В(&ВыбранныеСпринты)
		|	И СпринтыОбъекта.Спринт ЕСТЬ NULL
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СпринтыОбъекта.Спринт КАК Спринт,
		|	СпринтыОбъекта.Трудозатраты КАК Трудозатраты,
		|	СпринтыОбъекта.Трудозатраты КАК ТрудозатратыИсходные,
		|	СпринтыОбъекта.ТрудозатратыТестирование КАК ТрудозатратыТестирование,
		|	СпринтыОбъекта.ТрудозатратыТестирование КАК ТрудозатратыТестированиеИсходные,
		|	СпринтыОбъекта.Пометка КАК Пометка,
		|	СпринтыОбъекта.Добавленный КАК Добавленный,
		|	СпринтыОбъекта.ДатаНачала КАК ДатаНачала
		|ПОМЕСТИТЬ ПодготовленныеДанные
		|ИЗ
		|	СпринтыОбъекта КАК СпринтыОбъекта
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ДобавленныеСпринты.Спринт,
		|	ДобавленныеСпринты.Трудозатраты,
		|	ДобавленныеСпринты.Трудозатраты,
		|	ДобавленныеСпринты.ТрудозатратыТестирование,
		|	ДобавленныеСпринты.ТрудозатратыТестирование,
		|	ДобавленныеСпринты.Пометка,
		|	ДобавленныеСпринты.Добавленный,
		|	ДобавленныеСпринты.ДатаНачала
		|ИЗ
		|	ДобавленныеСпринты КАК ДобавленныеСпринты
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ПланируемыеТрудозатраты.Трудозатраты КАК ТрудозатратыНачальные,
		|	0 КАК ТрудозатратыНачальныеТестирование
		|ПОМЕСТИТЬ ПланируемыеТрудозатраты
		|ИЗ
		|	РегистрСведений.ПланируемыеТрудозатраты КАК ПланируемыеТрудозатраты
		|ГДЕ
		|	ПланируемыеТрудозатраты.Объект = &Объект
		|	И ПланируемыеТрудозатраты.ТипТрудозатрат = ЗНАЧЕНИЕ(Перечисление.ТипыТрудозатрат.Разработка)
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	0,
		|	ПланируемыеТрудозатраты.Трудозатраты
		|ИЗ
		|	РегистрСведений.ПланируемыеТрудозатраты КАК ПланируемыеТрудозатраты
		|ГДЕ
		|	ПланируемыеТрудозатраты.Объект = &Объект
		|	И ПланируемыеТрудозатраты.ТипТрудозатрат = ЗНАЧЕНИЕ(Перечисление.ТипыТрудозатрат.Тестирование)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СУММА(ПланируемыеТрудозатраты.ТрудозатратыНачальные) КАК ТрудозатратыНачальные,
		|	СУММА(ПланируемыеТрудозатраты.ТрудозатратыНачальныеТестирование) КАК ТрудозатратыНачальныеТестирование
		|ИЗ
		|	ПланируемыеТрудозатраты КАК ПланируемыеТрудозатраты
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ПодготовленныеДанные.Спринт КАК Спринт,
		|	ПодготовленныеДанные.Трудозатраты КАК Трудозатраты,
		|	ПодготовленныеДанные.ТрудозатратыИсходные КАК ТрудозатратыИсходные,
		|	ПодготовленныеДанные.ТрудозатратыТестирование КАК ТрудозатратыТестирование,
		|	ПодготовленныеДанные.ТрудозатратыТестированиеИсходные КАК ТрудозатратыТестированиеИсходные,
		|	ПодготовленныеДанные.Пометка КАК Пометка,
		|	ПодготовленныеДанные.Добавленный КАК Добавленный
		|ИЗ
		|	ПодготовленныеДанные КАК ПодготовленныеДанные
		|
		|УПОРЯДОЧИТЬ ПО
		|	ПодготовленныеДанные.ДатаНачала";
		#КонецОбласти
		
		Запрос.УстановитьПараметр("Объект", Объект);
		Запрос.УстановитьПараметр("ВыбранныеСпринты", ВыбранныеСпринты);
		Запрос.УстановитьПараметр("ФильтрСпринты", ВыбранныеСпринты.Количество() > 0);
		Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДатаСеанса());
		Пакеты = Запрос.ВыполнитьПакет();
		
		Таблица = Пакеты[Пакеты.ВГраница()].Выгрузить();		 
		ЗначениеВРеквизитФормы(Таблица, "ТаблицаСпринтов"); 
				
		Выборка = Пакеты[Пакеты.ВГраница() - 1].Выбрать();
		Выборка.Следующий();
		ТрудозатратыНачальные = Выборка.ТрудозатратыНачальные; 
		ТрудозатратыНачальныеТестирование = Выборка.ТрудозатратыНачальныеТестирование;
		
		НераспределенныеТрудозатраты = ТрудозатратыНачальные - ТаблицаСпринтов.Итог("Трудозатраты"); 
		НераспределенныеТрудозатратыТестирование = ТрудозатратыНачальныеТестирование - ТаблицаСпринтов.Итог("ТрудозатратыТестирование");
		Если НераспределенныеТрудозатраты > 0 ИЛИ НераспределенныеТрудозатратыТестирование > 0 Тогда
			НоваяСтрока = ТаблицаСпринтов.Добавить();
			НоваяСтрока.Спринт = Документы.Спринт.ПустаяСсылка();
			НоваяСтрока.Трудозатраты = НераспределенныеТрудозатраты;
			НоваяСтрока.ТрудозатратыТестирование = НераспределенныеТрудозатратыТестирование;
		КонецЕсли;
	Иначе                                                      
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	СоставСпринтов.Спринт КАК Спринт,
		|	СУММА(ТрудозатратыФакт.Затрата) КАК Затрата
		|ИЗ
		|	РегистрСведений.СоставСпринтов КАК СоставСпринтов
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Спринт КАК Спринты
		|		ПО СоставСпринтов.Спринт = Спринты.Ссылка
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Трудозатраты КАК ТрудозатратыФакт
		|		ПО (ТрудозатратыФакт.Объект = СоставСпринтов.Объект)
		|ГДЕ
		|	ТрудозатратыФакт.РольПользователя = ЗНАЧЕНИЕ(Справочник.РолиПользователей.Тестировщик)
		|	И ТрудозатратыФакт.Период МЕЖДУ Спринты.ДатаНачала И Спринты.ДатаОкончания
		|	И СоставСпринтов.Объект = &Объект
		|
		|СГРУППИРОВАТЬ ПО
		|	СоставСпринтов.Спринт,
		|	Спринты.ДатаОкончания
		|
		|УПОРЯДОЧИТЬ ПО
		|	Спринты.ДатаОкончания";
		
		Запрос.УстановитьПараметр("Объект", Объект);
		
		Выборка = Запрос.Выполнить().Выбрать();
				
		Пока Выборка.Следующий() Цикл
			ДобавитьЗапись = ТаблицаСпринтов.Добавить();
			ДобавитьЗапись.Спринт = Выборка.Спринт;
			ДобавитьЗапись.Трудозатраты = Выборка.Затрата;
		КонецЦикла;
	КонецЕсли;
				
КонецПроцедуры 

&НаСервере
Процедура СохранитьТрудозатраты()
	
	ИтогоТрудозатраты = 0;
	ИтогоТрудозатратыТестирование = 0;
	
	Для Каждого Строка Из ТаблицаСпринтов Цикл
		Если НЕ Строка.Спринт.Пустая() Тогда
			// Запись плановых трудозатрат на разработку по спринту 
			Если Строка.Трудозатраты <> Строка.ТрудозатратыИсходные ИЛИ Строка.Добавленный Тогда
				РегистрыСведений.ПланируемыеТрудозатратыПоСпринтам.Добавить(Объект, Строка.Спринт, Перечисления.ТипыТрудозатрат.Разработка, Строка.Трудозатраты);
			КонецЕсли;
			
			// Запись плановых трудозатрат на тестирование по спринту
			Если Строка.ТрудозатратыТестирование <> Строка.ТрудозатратыТестированиеИсходные ИЛИ Строка.Добавленный Тогда
				РегистрыСведений.ПланируемыеТрудозатратыПоСпринтам.Добавить(Объект, Строка.Спринт, Перечисления.ТипыТрудозатрат.Тестирование, Строка.ТрудозатратыТестирование);
			КонецЕсли;
			
			ИтогоТрудозатраты = ИтогоТрудозатраты + Строка.Трудозатраты; 
			ИтогоТрудозатратыТестирование = ИтогоТрудозатратыТестирование + Строка.ТрудозатратыТестирование;
		КонецЕсли;
	КонецЦикла;
	
	// Запись общих плановых трудозатрат на разработку или тестирование
	Если РедактированиеПлановыхТрудозатратНаРазработку 
		ИЛИ РедактированиеПлановыхТрудозатратНаТестирование Тогда
		
		ОписаниеИзменений = ОбщегоНазначения.ПолучитьСостояниеОбъектаДоЗаписи(Объект);
		ОписаниеИзменений.Вставить("ОписаниеИзменилось", Ложь);	
		
		ДанныеРеквизитов = ОписаниеИзменений.Значения.Реквизиты;
		
		Если ИтогоТрудозатраты <> ТрудозатратыНачальные Тогда
			ДанныеРеквизитов.Вставить("ОценкаТрудозатрат", ИтогоТрудозатраты);
			ТрудозатратыНачальные = ИтогоТрудозатраты;
		КонецЕсли;
		
		Если ИтогоТрудозатратыТестирование <> ТрудозатратыНачальныеТестирование Тогда
			ДанныеРеквизитов.Вставить("ОценкаТрудозатратТестирования", ИтогоТрудозатратыТестирование);
			ТрудозатратыНачальныеТестирование = ИтогоТрудозатратыТестирование;
		КонецЕсли;
		
		ОбщегоНазначения.ОбработатьИзменениеОбъекта(Объект, ОписаниеИзменений);
		
		Если ДанныеРеквизитов.Свойство("ОценкаТрудозатрат") Тогда
			УчетТрудозатрат.ЗаписатьПлановыеТрудозатраты(Объект, ИтогоТрудозатраты, Перечисления.ТипыТрудозатрат.Разработка);  
		КонецЕсли;
		
		Если ДанныеРеквизитов.Свойство("ОценкаТрудозатратТестирования") Тогда
			УчетТрудозатрат.ЗаписатьПлановыеТрудозатраты(Объект, ИтогоТрудозатратыТестирование, Перечисления.ТипыТрудозатрат.Тестирование);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры 

#КонецОбласти

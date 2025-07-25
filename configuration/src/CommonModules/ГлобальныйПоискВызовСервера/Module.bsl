///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Функция - Получить объекты по тэгу
//
// Параметры:
//  СтрокаПоиска - Строка - Строка поиска
// 
// Возвращаемое значение:
//  Массив - Массив структур найденных объектов
//
Функция ПолучитьОбъектыПоТэгу(СтрокаПоиска) Экспорт	
		
	// Теги в строке по идее должны просто начинаться с #, тогда я бы мог делать СтрРазделить и получить массив
	// , но по факту есть теги типа "спринт#1wms", в таком случае такой тег искаться не будет, поэтому
	// нужно теги делить в строке поиске по такой связке " #". Что бы первая # отрабатывала, всегда добавляю пробел.
	
	Строка = " " + СтрокаПоиска; 
	Строка = СтрЗаменить(Строка, " #", Символы.ПС);
	МассивТегов = СтрРазделить(Строка, Символы.ПС, Ложь);
	
	Если МассивТегов.Количество() = 0 Тогда 
		Возврат Новый Массив;
	КонецЕсли;
	
	Запрос = ПолучитьЗапросПоТегам(МассивТегов); 
	
	Данные = Новый Массив;
	Результат = Запрос.Выполнить();	
	Выборка = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам); 
	
	Пока Выборка.Следующий() Цикл   
		
		Теги = Выборка.Выбрать(); 
		Представление = Новый Массив;
		Представление.Добавить(Строка(Выборка.Объект));
		Представление.Добавить(Символы.ПС);
		
		Пока Теги.Следующий() Цикл      
			
			Тег = Строка(Теги.Тег); 
			ВрегСтрокаПоиска = Теги.СтрокаПоиска;
			СтрокаПоиска = "";
			Остаток = ""; 
			
			Если Врег(Тег) = ВрегСтрокаПоиска Тогда
				СтрокаПоиска = Тег;
			Иначе 
				СтрокаПоиска = Лев(Тег, СтрДлина(ВрегСтрокаПоиска));
				Остаток = Сред(Тег, СтрДлина(ВрегСтрокаПоиска) + 1);
			КонецЕсли;  	
			  
			СтрокаПоиска = ?(Лев(СтрокаПоиска, 1) = "#", "", "#") + СтрокаПоиска;
			Представление.Добавить(Новый ФорматированнаяСтрока(СтрокаПоиска, Новый Шрифт(,, Истина)));
			
			Если Остаток <> "" Тогда 
		   		Представление.Добавить(Остаток);
			КонецЕсли;
			
			Представление.Добавить(", ");
			
		КонецЦикла;
		
		// Удаляю последнюю запятую
		Представление.Удалить(Представление.ВГраница());
		Структура = Новый Структура;
		Структура.Вставить("Объект", Новый ФорматированнаяСтрока(Представление));
		Структура.Вставить("Ссылка", ПолучитьНавигационнуюСсылку(Выборка.Объект));
		Данные.Добавить(Структура); 
		
	КонецЦикла; 
	
	Возврат Данные;
	
КонецФункции   
	
// Функция - Раскодирует URL 
//
// Параметры:
//  URL - Строка - URL
// 
// Возвращаемое значение:
//  Строка - Раскодированный URL
//
Функция РаскодироватьURL(URL) Экспорт	
	
	Возврат РаскодироватьСтроку(URL, СпособКодированияСтроки.КодировкаURL);
	
КонецФункции  

#КонецОбласти   

#Область СлужебныеПроцедурыИФункции

Функция ПолучитьЗапросПоТегам(МассивТегов)	
		
	// Тегов может быть много, поэтому для каждого тега ищу свой список. По ним ищу объекты.
	// Потом ищу такие объекты, где для каждого списка найденных тегов есть хотя бы один элемент.
	Запрос = Новый Запрос;  
	ОбластьСоединения = "";  
	МассивУсловий = Новый Массив;
	МассивПорядок = Новый Массив;
	МассивОбщиеТэги = Новый Массив;
	МассивТекстов = Новый Массив;
	
	ШаблоныЗапроса = ПолучитьШаблоныЗапроса(); 
	Разделитель = 
	";
	|////////////////////////////////////////////////////////////////////////////////
	|";
	
	Счетчик = 1;                                              
	Для Каждого Тег Из МассивТегов Цикл 
		
		МассивТекстов.Добавить(СтрШаблон(ШаблоныЗапроса.Получить("ШаблонВыборка"), Счетчик));
		ОбластьСоединения = ОбластьСоединения + СтрШаблон(ШаблоныЗапроса.Получить("ШаблонСоединения"), Счетчик);
		МассивУсловий.Добавить(СтрШаблон(ШаблоныЗапроса.Получить("ШаблонУсловия"), Счетчик));
		МассивПорядок.Добавить(СтрШаблон(ШаблоныЗапроса.Получить("ШаблонПорядок"), Счетчик)); 
		МассивОбщиеТэги.Добавить(СтрШаблон(ШаблоныЗапроса.Получить("ШаблонОбщиеТеги"), Счетчик, 
			?(МассивОбщиеТэги.Количество() = 0, "ПОМЕСТИТЬ ОбщиеТеги", "")));
		
		СтрокаТег = СокрЛП(Тег);
		Запрос.УстановитьПараметр("Наименование" + Счетчик, Врег("#" + СтрокаТег)); 
		Запрос.УстановитьПараметр("Длина" + Счетчик, СтрДлина(СтрокаТег) + 1);
		Запрос.УстановитьПараметр("НаименованиеБезРешетки" + Счетчик, Врег(СтрокаТег));
		Запрос.УстановитьПараметр("ДлинаБезРешетки" + Счетчик, СтрДлина(СтрокаТег)); 	
		Счетчик = Счетчик + 1;
		
	КонецЦикла;
	
	МассивТекстов.Добавить(СтрСоединить(МассивОбщиеТэги, " ОБЪЕДИНИТЬ "));
	
	Текст =
	"ВЫБРАТЬ РАЗЛИЧНЫЕ ПЕРВЫЕ 100
	|	ТегиОбъектов.Объект КАК Объект,
	|	СУММА(" + СтрСоединить(МассивПорядок, " + ") + ") КАК Порядок
	|ПОМЕСТИТЬ Данные
	|ИЗ
	|	РегистрСведений.ТегиОбъектов КАК ТегиОбъектов" +
	ОбластьСоединения +
	"СГРУППИРОВАТЬ ПО
	|	ТегиОбъектов.Объект
	|
	|ИМЕЮЩИЕ" +
	СтрСоединить(МассивУсловий, " И ") +
	"УПОРЯДОЧИТЬ ПО
	|	Порядок,
	|	Объект";
	МассивТекстов.Добавить(Текст);
	
	Текст =
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Данные.Объект КАК Объект,
	|	ОбщиеТеги.Ссылка КАК Тег,
	|	МАКСИМУМ(ОбщиеТеги.СтрокаПоиска) КАК СтрокаПоиска
	|ИЗ
	|	Данные КАК Данные
	|		ПОЛНОЕ СОЕДИНЕНИЕ ОбщиеТеги КАК ОбщиеТеги
	|		ПО (ИСТИНА)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ТегиОбъектов КАК ТегиОбъектов
	|		ПО (Данные.Объект = ТегиОбъектов.Объект)
	|			И (ТегиОбъектов.Тег = ОбщиеТеги.Ссылка)
	|СГРУППИРОВАТЬ ПО
	|	Данные.Объект,
	|	ОбщиеТеги.Ссылка
	|ИТОГИ
	|ПО
	|	Объект";
	МассивТекстов.Добавить(Текст);	 
	
	Запрос.Текст = СтрСоединить(МассивТекстов, Разделитель);
	
	Возврат Запрос;
	
КонецФункции   

Функция ПолучитьШаблоныЗапроса() 
	
	ШаблонВыборка = 
	"ВЫБРАТЬ
	|	Теги.Ссылка КАК Ссылка,
	|	&Наименование%1 КАК СтрокаПоиска,
	|	0 КАК Порядок
	|ПОМЕСТИТЬ Тэги%1
	|ИЗ
	|	Справочник.Теги КАК Теги
	|ГДЕ
	|	НЕ Теги.ПометкаУдаления
	|	И ВРЕГ(Теги.Наименование) = &Наименование%1
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	Теги.Ссылка,
	|	&НаименованиеБезРешетки%1 КАК СтрокаПоиска,
	|	0 КАК Порядок
	|ИЗ
	|	Справочник.Теги КАК Теги
	|ГДЕ
	|	НЕ Теги.ПометкаУдаления
	|	И ВРЕГ(Теги.Наименование) = &НаименованиеБезРешетки%1
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	Теги.Ссылка КАК Ссылка,
	|	&Наименование%1 КАК СтрокаПоиска,
	|	10 КАК Порядок
	|ИЗ
	|	Справочник.Теги КАК Теги
	|ГДЕ
	|	НЕ Теги.ПометкаУдаления
	|	И ВРЕГ(ПОДСТРОКА(Теги.Наименование, 1, &Длина%1)) = &Наименование%1
	|	И НЕ ВРЕГ(Теги.Наименование) = &Наименование%1
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	Теги.Ссылка,
	|	&НаименованиеБезРешетки%1 КАК СтрокаПоиска,
	|	10 КАК Порядок
	|ИЗ
	|	Справочник.Теги КАК Теги
	|ГДЕ
	|	НЕ Теги.ПометкаУдаления
	|	И ВРЕГ(ПОДСТРОКА(Теги.Наименование, 1, &ДлинаБезРешетки%1)) = &НаименованиеБезРешетки%1
	|	И НЕ ВРЕГ(Теги.Наименование) = &НаименованиеБезРешетки%1
	|";
	
	ШаблонОбщиеТеги =  
	"ВЫБРАТЬ 
    |	Теги.Ссылка,
	|	Теги.СтрокаПоиска
	|%2
	|ИЗ
	|	Тэги%1 КАК Теги";  
	
	ШаблонСоединения = 
	"		ЛЕВОЕ СОЕДИНЕНИЕ Тэги%1 КАК Тэги%1
	|		ПО (Тэги%1.Ссылка = ТегиОбъектов.Тег)";
	
	ШаблонУсловия = 
	"	СУММА(ВЫБОР
	|			КОГДА Тэги%1.Ссылка ЕСТЬ NULL
	|				ТОГДА 0
	|			ИНАЧЕ 1
	|		КОНЕЦ) >= 1
	|";
	
	ШаблонПорядок = "ЕСТЬNULL(Тэги%1.Порядок, 0)"; 
	
	Шаблоны = Новый Соответствие;
	Шаблоны.Вставить("ШаблонВыборка", ШаблонВыборка);
	Шаблоны.Вставить("ШаблонСоединения", ШаблонСоединения);
	Шаблоны.Вставить("ШаблонУсловия", ШаблонУсловия);
	Шаблоны.Вставить("ШаблонПорядок", ШаблонПорядок);
    Шаблоны.Вставить("ШаблонОбщиеТеги", ШаблонОбщиеТеги);
	
	Возврат Шаблоны;
	
КонецФункции

#КонецОбласти

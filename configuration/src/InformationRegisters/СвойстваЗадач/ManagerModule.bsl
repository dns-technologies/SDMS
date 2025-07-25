///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер ИЛИ ВнешнееСоединение ИЛИ ТолстыйКлиентОбычноеПриложение Тогда
	
#Область ПрограммныйИнтерфейс

// Добавляет запиись в регистр сведений СвойстваЗадач
//
// Параметры:
//  Объект			 - ДокументСсылка.Задача - ссылка на задачу
//  ДанныеОбъекта	 - Структура			 - дополнительные данные задачи
//  			* Испольнитель	 - СправочникСсылка.Пользователи	 - текущий исполнитель задачи
//  			* НовыйСтатус	 - СправочникСсылка.СтатусыОбъектов	 - статус задачи
//  			* Порядок	 - Число	 - порядок заявки в очереди
//  			* ПроцентВыполнения	 - Число	 - процент выполнения из реквизита задачи
//  ДатаЗаписи		 - Дата (дата и	время)	 - дата, на которую требуется добавить запись
//  Заблокировать	 - Булево				 - признак необходимости блокировки набора записей регистра сведений
//
Процедура Добавить(Знач Объект, Знач ДанныеОбъекта, Знач ДатаЗаписи = Неопределено, Знач Заблокировать = Истина) Экспорт
	
	Период = ТекущаяДатаСеанса();
	
	Если ДатаЗаписи <> Неопределено Тогда
		Период = ДатаЗаписи;
	КонецЕсли;
	
	Если Заблокировать Тогда
		БлокировкаДанных = Новый БлокировкаДанных;
		ЭлементБлокировки = БлокировкаДанных.Добавить("РегистрСведений.СвойстваЗадач");
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		
		ЭлементБлокировки.УстановитьЗначение("Период", Период);
		ЭлементБлокировки.УстановитьЗначение("Объект", Объект);
		
		БлокировкаДанных.Заблокировать();
	КонецЕсли;
	
	ЭтоСлужебныйСтатус = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДанныеОбъекта.НовыйСтатус, "Предопределенный");
	Если НЕ ЭтоСлужебныйСтатус Тогда
		Статус = РаботаСПроцессами.ПолучитьСсылкуНаСлужебныйСтатус(ДанныеОбъекта.НовыйСтатус);
		ПользовательскийСтатус = ДанныеОбъекта.НовыйСтатус;
	Иначе
		РодительскийСтатус = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДанныеОбъекта.НовыйСтатус, "Родитель");	
		Если РодительскийСтатус = Справочники.СтатусыОбъектов.ПустаяСсылка() Тогда
			Статус = ДанныеОбъекта.НовыйСтатус;
			ПользовательскийСтатус = Справочники.СтатусыОбъектов.ПустаяСсылка();
		Иначе
			Статус = РодительскийСтатус;
			ПользовательскийСтатус = РаботаСПроцессами.ПолучитьСсылкуНаСлужебныйСтатус(ДанныеОбъекта.НовыйСтатус);			
		КонецЕсли;
	КонецЕсли;
	
	НаборЗаписей = СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Период.Установить(Период);
	НаборЗаписей.Отбор.Объект.Установить(Объект);
	
	НоваяЗапись = НаборЗаписей.Добавить();
	НоваяЗапись.Период = Период;
	НоваяЗапись.Объект = Объект;
	НоваяЗапись.Исполнитель = ДанныеОбъекта.НовыйИсполнитель;
	НоваяЗапись.Статус = Статус;
	НоваяЗапись.ПользовательскийСтатус = ПользовательскийСтатус;
	НоваяЗапись.Порядок = ДанныеОбъекта.Порядок;
	НоваяЗапись.ПроцентВыполнения = ДанныеОбъекта.ПроцентВыполнения;
	НоваяЗапись.Автор = ПараметрыСеанса.ТекущийПользователь;
	
	НаборЗаписей.Записать();
	
КонецПроцедуры

// Возвращает пользователя, который отправлял задачу на доработку
//
// Параметры:
//  Задача  - ДокументСсылка.Задача - ссылка на документ задача
//
// Возвращаемое значение:
//  СправочникСсылка.Пользователи - пользователь, который отправлял задачу на доработку или пустая ссылка
//
Функция ОтправительНаДоработку(Знач Задача) Экспорт
	
	Запрос = Новый Запрос;
	
#Область ТекстЗапроса

	Запрос.Текст =
	"ВЫБРАТЬ
	|	СвойстваЗадач.Объект КАК Объект,
	|	МАКСИМУМ(СвойстваЗадач.Период) КАК Период
	|ПОМЕСТИТЬ ЗадачаНаДоработке
	|ИЗ
	|	РегистрСведений.СвойстваЗадач КАК СвойстваЗадач
	|ГДЕ
	|	СвойстваЗадач.Объект = &Объект
	|	И СвойстваЗадач.Статус = ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.НаДоработку)
	|
	|СГРУППИРОВАТЬ ПО
	|	СвойстваЗадач.Объект
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗадачаНаДоработке.Объект КАК Объект,
	|	МАКСИМУМ(СвойстваЗадач.Период) КАК Период
	|ПОМЕСТИТЬ ЗадачаДоНаДоработке
	|ИЗ
	|	ЗадачаНаДоработке КАК ЗадачаНаДоработке
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.СвойстваЗадач КАК СвойстваЗадач
	|		ПО (СвойстваЗадач.Объект = ЗадачаНаДоработке.Объект)
	|			И (СвойстваЗадач.Период < ЗадачаНаДоработке.Период)
	|			И (СвойстваЗадач.Статус <> ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.НаДоработку))
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗадачаНаДоработке.Объект
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗадачаДоНаДоработке.Объект КАК Объект,
	|	СвойстваЗадач.Исполнитель КАК Исполнитель
	|ИЗ
	|	ЗадачаДоНаДоработке КАК ЗадачаДоНаДоработке
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.СвойстваЗадач КАК СвойстваЗадач
	|		ПО (СвойстваЗадач.Объект = ЗадачаДоНаДоработке.Объект)
	|			И (СвойстваЗадач.Период = ЗадачаДоНаДоработке.Период)";
	
#КонецОбласти
	
	Запрос.УстановитьПараметр("Объект", Задача);
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		ОтправительНаДоработку = Справочники.Пользователи.ПустаяСсылка();
	Иначе
		ОтправительНаДоработку = РезультатЗапроса.Выгрузить().ВыгрузитьКолонку("Исполнитель").Получить(0);
	КонецЕсли;
	
	Возврат ОтправительНаДоработку;
	
КонецФункции

#КонецОбласти
	
#КонецЕсли

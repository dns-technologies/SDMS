///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Запуск и завершение работы системы

#Область ПрограммныйИнтерфейс

#Область ОбновлениеДанных

// Выполняеи обновление данных и возвращает признак успеха
// 
// Возвращаемое значение:
//  Обновление выполнено - булево
//
Функция ВыполнитьОбновлениеДанных() Экспорт
	
	Если НЕ (РольДоступна("ПолныеПрава") ИЛИ РольДоступна("Администратор")) Тогда 
		Текст = СтрШаблон("Выполнять запуск с обновлением данных необходимо пользователю с полными правами");
		ЗаписьЖурналаРегистрации("Обновление данных: запуск", УровеньЖурналаРегистрации.Ошибка,,, Текст);
		Возврат Ложь;
	КонецЕсли;
	
	Обработчики = ПолучитьОбработчикиДанных();  
	ТекущаяВерсия = Метаданные.Версия;      
	Выполнено = Истина;
	
	Попытка
		Для Каждого Строка Из Обработчики Цикл
			Если Строка.Версия = "*" ИЛИ Строка.Версия = ТекущаяВерсия Тогда    
				Выполнить(Строка.Процедура + "()");
			КонецЕсли;
		КонецЦикла;      
	Исключение        
		Выполнено = Ложь;                                                                                     
		Текст = СтрШаблон("Ошибка при обновлении данных: %1", ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		ЗаписьЖурналаРегистрации("Обновление данных: " + Строка.Процедура, УровеньЖурналаРегистрации.Ошибка,,, Текст);
	КонецПопытки;
	
	Если Выполнено Тогда          
		УстановитьПривилегированныйРежим(Истина);
		Константы.ПоследняяВерсияКонфигурации.Установить(Метаданные.Версия);
		УстановитьПривилегированныйРежим(Ложь);
	КонецЕсли;
	
	Возврат Выполнено;
	
КонецФункции

Процедура ЗаполнитьПараметрСеансаДоступенВнешнийСайт(Знач ДоступенВнешнийСайт) Экспорт
	
	ПараметрыСеанса.ДоступенВнешнийСайт = ДоступенВнешнийСайт;
	
КонецПроцедуры

// Получает настройки обновления данных
// 
// Возвращаемое значение:
//  Структура - настройки обновления
//
Функция ПараметрыОбновления() Экспорт
	
	Структура = Новый Структура;             
	// Пока не нужно вызывать
	Структура.Вставить("НужноОбновление", НеобходимоОбновлениеДанныхИнформационнойБазы());
	Структура.Вставить("ОткрытиеМастераНастройки", НеобходимоОткрытиеМастераНастройки());
	
	Возврат Структура;
	
КонецФункции  

#КонецОбласти

// Запускает методы после обновления ИБ.
//
Процедура ВыполнитьОбновлениеИнформационнойБазы() Экспорт
	
	ИнтеграцияДополнительныхПодсистем.ОбновлениеИнформационнойБазы(Истина);
	
КонецПроцедуры

// Определяет, была ли изменена конфигурация базы данных динамически после старта
// 
// Возвращаемое значение:
//  Булево - Истина, если в процессе работы пользователя с информационной 
//			 базой произошло обновление конфигурации базы данных
//
Функция КонфигурацияБазыДанныхОбновленаДинамически() Экспорт
	
	Возврат КонфигурацияБазыДанныхИзмененаДинамически();
	
КонецФункции

// Проверяет активность блокировки сеансов пользователей информационной базы 
// и возвращает параметры блокироки.
//
// Возвращаемое значение:
//  Структура c параметрами блокировки.
//
Функция ПолучитьБлокировкуСеансовПользователей() Экспорт
		
	// Описание блокировки сеансов пользователей
	БлокировкаСеансов = ПолучитьБлокировкуСеансов();
	
	// Параметры текущей блокировки, которые будут возвращены клиенту
	ПараметрыБлокировки = Новый Структура;
	ПараметрыБлокировки.Вставить("Установлена", БлокировкаСеансов.Установлена);
	
	// Если блокировка установлена, нужно подготовить для клиента дополнительные данные
	Если ПараметрыБлокировки.Установлена Тогда
		// Время, в которое все незавершенные сеансы будут завершены принудительно. На самостоятельное
		// завершение работы пользователем отводится 5 минут.
		ВремяОтключенияСеанса = БлокировкаСеансов.Начало + 300;
		ПредставлениеВремениОтключения = Формат(ВремяОтключенияСеанса, "ДФ='''В'' HH ''ч.'' mm ''мин.'''");
		
		ПараметрыБлокировки.Вставить("ВремяОтключенияСеанса", ПредставлениеВремениОтключения);
		ПараметрыБлокировки.Вставить("ЗавершитьСеанс", Ложь);
		
		// Определение необходимости принудительного завершения сеанса. Если у
		// у пользователя отсутствует роль ОбновлениеКонфигурацииБазыДанных, такого 
		// пользователя необходимо принудительно отключить от системы при превышении
		// времени ожидания.
		Если НЕ УправлениеДоступомПовтИсп.ПроверитьДоступностьРоли("ОбновлениеКонфигурацииБазыДанных") Тогда
			
			Если ВремяОтключенияСеанса <= ТекущаяДатаСеанса() Тогда
				ПараметрыБлокировки.ЗавершитьСеанс = Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Возврат ПараметрыБлокировки;
	
КонецФункции

// Возвращает настройки клиентского приложения
//
// Параметры:
// ЧитатьОткрытыеОкна - Булево - флаг чтения список открытых окон
//
// Возвращаемое значение:
//   Структура - настройки клиентского приложения
//
Функция ПолучитьНастройкиКлиентскогоПриложения(ЧитатьОткрытыеОкна = Истина) Экспорт
	
	Настройки = Новый Структура;
	
	Если ЧитатьОткрытыеОкна Тогда
		ОписаниеНастройки = ПриложениеКлиентСервер.ОписаниеНастройкиСпискаОткрытыхОкон();
		ОткрытыеОкна = ОбщегоНазначенияВызовСервера.ЗагрузитьСистемнуюНастройку(ОписаниеНастройки.КлючОбъекта, 
			ОписаниеНастройки.КлючНастроек);
	Иначе 
		ОткрытыеОкна = Неопределено;
	КонецЕсли;
	
	Если ОткрытыеОкна = Неопределено ИЛИ ТипЗнч(ОткрытыеОкна) <> Тип("Массив") Тогда
		ОткрытыеОкна = Новый Массив;
	КонецЕсли;
	
	Настройки.Вставить("ОткрытыеОкна", ОткрытыеОкна);
	ИнтеграцияДополнительныхПодсистем.ДополнитьНастройкиКлиентскогоПриложения(Настройки);
	
	Возврат Настройки;
	
КонецФункции

// Функция - При начале работы системы после выполнения проверок
//
// Параметры:
//  ДатаКлиента		 - Дата		 - дата на клиентском устройстве
//  ДанныеКлиента	 - Структура - данные клиента
//   (см. функцию СтатистикаВходовПользователей.Добавить)
// 
// Возвращаемое значение:
//  Результат - Структура
//  *АвтоматическоеВосстановление
//  *Настройки
//
Функция ПриНачалеРаботыСистемыПослеВыполненияПроверок(Знач ДатаКлиента, Знач ДанныеКлиента) Экспорт

	// Если автовосстановление окон отключено, то настройки даже читать нельзя, так как они тут же очищаются.
	АвтоматическоеВосстановление = РегистрыСведений.НастройкиПользователя.ЗначениеНастройки(
		ПараметрыСеанса.ТекущийПользователь, ПланыВидовХарактеристик.ВидыНастроекПользователя.АвтоматическоеВосстановление);
		
	Настройки = ПриложениеВызовСервера.ПолучитьНастройкиКлиентскогоПриложения(АвтоматическоеВосстановление); 		
	СмещениеВремени = Цел((ДатаКлиента - ТекущаяДата()) / 3600);
	РегистрыСведений.ЗначенияДополнительныхРеквизитовОбъектов.УстановитьЗначениеДополнительногоРеквизита(
		ПараметрыСеанса.ТекущийПользователь, ПланыВидовХарактеристик.ВидыДополнительныхРеквизитов.СмещениеВремени,
		СмещениеВремени, Истина);	
		
	РегистрыСведений.СтатистикаВходовПользователей.Добавить(ПараметрыСеанса.ТекущийПользователь, ДанныеКлиента);
	КоличествоАвтосохранений = РегистрыСведений.АвтосохраненныеОписания.КоличествоАвтосохраненийТекущегоПользователя();
	
	Данные = Новый Структура("АвтоматическоеВосстановление, Настройки, КоличествоАвтосохранений",
		АвтоматическоеВосстановление, Настройки, КоличествоАвтосохранений);
	
	Если ПараметрыСеанса.ДоступенВнешнийСайт Тогда
		Данные.Вставить("ДанныеДляВнешнегоСайта", ИнструментыСервер.ПолучитьДанныеДляПанелиИнструментов());
	КонецЕсли;
	
	Возврат Данные;
	
КонецФункции
	
// Проверяет разрешено ли пользователю работать в системе
// 
// Возвращаемое значение:
//  ПроверяемыеПараметры - Структура
//
Функция ПроверитьВозможностьРаботыПользователя(Знач ДоступенВнешнийСайт) Экспорт
	
	ПроверяемыеПараметры = Новый Структура;
	
	УстановитьПривилегированныйРежим(Истина);
	ЕстьПользователь = Булево(ПользователиИнформационнойБазы.ПолучитьПользователей().Количество());
	ПроверяемыеПараметры.Вставить("ЕстьПользователи", ЕстьПользователь);
	УстановитьПривилегированныйРежим(Ложь);     

	ПользовательОпределен = ЗначениеЗаполнено(ПараметрыСеанса.ТекущийПользователь);
	ПроверяемыеПараметры.Вставить("ПользовательОпределен", ПользовательОпределен);
	
	Если ПользовательОпределен Тогда
		ДанныеПользователя = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ПараметрыСеанса.ТекущийПользователь, "Недействителен, Служебный");
		
		ПроверяемыеПараметры.Вставить("Недействительный", ДанныеПользователя.Недействителен);
		ПроверяемыеПараметры.Вставить("Служебный", ДанныеПользователя.Служебный);
	КонецЕсли;
	
	ПроверяемыеПараметры.Вставить("ЗапрещенДоступВебКлиент", Ложь);
	Если КлиентскоеПриложение.ТипПриложения() = ТипКлиентскогоПриложения.ВебКлиент
		И НЕ УправлениеДоступомПовтИсп.ПроверитьДоступностьРоли("Администратор") И НЕ ДоступенВнешнийСайт Тогда
		
		ПроверяемыеПараметры.ЗапрещенДоступВебКлиент = Константы.ЗапретитьДоступВебКлиент.Получить();
		ПроверяемыеПараметры.Вставить("АдресПубликации", ПараметрыСеанса.АдресаWebОкружения.АдресПубликацииИнформационнойБазы);
	КонецЕсли;
	
	Возврат ПроверяемыеПараметры;
	
КонецФункции

// Процедура - вызывает метод для замены начальной станицы и настройки интерфейса
//
// Параметры:
//  ДоступенВнешнийСайт	 - Булево - Признак, что приложение открыто в iframe
//
Процедура СформироватьНачальнуюСтраницу() Экспорт
	
	ТекущийСеанс = ПолучитьТекущийСеансИнформационнойБазы();
	ФоновоеЗадание = ТекущийСеанс.ПолучитьФоновоеЗадание();
	
	Если ФоновоеЗадание = Неопределено Тогда
		ТекущийПользователь = ПараметрыСеанса.ТекущийПользователь;
		
		Если ЗначениеЗаполнено(ТекущийПользователь) Тогда
			СлужебныйПользователь = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ТекущийПользователь, "Служебный");
		Иначе
			СлужебныйПользователь = Ложь;
		КонецЕсли;
		
		Если НЕ СлужебныйПользователь Тогда
			Приложение.НастроитьИнтерфейсКлиентскогоПриложения();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ОбновлениеДанных

Функция НеобходимоОткрытиеМастераНастройки()

	УстановитьПривилегированныйРежим(Истина);
	ВерсияМетаданных = Константы.ПоследняяВерсияКонфигурации.Получить();  
	УстановитьПривилегированныйРежим(Ложь);
	
	Возврат ПустаяСтрока(ВерсияМетаданных);
	
КонецФункции 

Функция НеобходимоОбновлениеДанныхИнформационнойБазы()
	
	УстановитьПривилегированныйРежим(Истина);
	
	ВерсияМетаданных = Метаданные.Версия;
	Если ПустаяСтрока(ВерсияМетаданных) Тогда
		ВерсияМетаданных = "0.0.0.0";
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	ВерсияДанных = Константы.ПоследняяВерсияКонфигурации.Получить(); 	
	УстановитьПривилегированныйРежим(Ложь);
	
	НеобходимоВыполнитьОбновление = ВерсияДанных <> ВерсияМетаданных;
	
	Возврат НеобходимоВыполнитьОбновление;
	
КонецФункции  

#КонецОбласти

// Возвращает настройки клиентского приложения
//
// Возвращаемое значение:
//   Строка - заголовок клиентского приложения
//
Функция ЗаголовокКлиентскогоПриложения() Экспорт
	
	ЭтоПродуктоваяБаза = ПовторноеИспользованиеВызовСервера.ЭтоПродуктоваяБаза();
	
	Префикс = ?(ЭтоПродуктоваяБаза, "", "[КОПИЯ] "); 
	
	Возврат Префикс + СтрШаблон("%1, версия %2", Метаданные.Синоним, Метаданные.Версия);
	
КонецФункции

// Выполняет поиск задачи по ее номеру. Номер может быть передан как строка с полным
// номером задачи (З0000025432), либо как число (25432).
//
// Параметры:
//  Номер - Строка, Число - номер задачи.
//
// Возвращаемое значение:
//  ДокументСсылка.Задача. Неопределено, если не удалось найти по номеру.
//
Функция НайтиЗадачуПоНомеру(Знач Номер) Экспорт
	
	ДлинаНомера = 11;
	
	Если СтрДлина(Номер) = ДлинаНомера И СтрНачинаетсяС(Номер, "З") Тогда
		ПодготовленныйНомер = Номер;
	Иначе
		ТипЧисло = Новый ОписаниеТипов("Число");
		ПодготовленныйНомер = ТипЧисло.ПривестиЗначение(Номер);
		
		Если ПодготовленныйНомер > 0 Тогда
			ПодготовленныйНомер = Формат(ПодготовленныйНомер, "ЧЦ=10; ЧВН=; ЧГ=0; ЧФ=ЗЧ");
		Иначе
			ВызватьИсключение "Не удалось преобразовать номер задачи: " + Строка(Номер);
		КонецЕсли;
	КонецЕсли;
	
	Возврат Документы.Задача.НайтиПоНомеру(ПодготовленныйНомер);
	
КонецФункции

Функция ПолучитьОбработчикиДанных()
	
	Обработчики = Новый ТаблицаЗначений;
	Обработчики.Колонки.Добавить("Версия");
	Обработчики.Колонки.Добавить("Процедура");
		
	Справочники.Пользователи.ДобавлениеОбработчиковОбновления(Обработчики);
	Справочники.ПрограммныеРоли.ДобавлениеОбработчиковОбновления(Обработчики);
	Справочники.РолиПользователей.ДобавлениеОбработчиковОбновления(Обработчики);
	Справочники.ИдентификаторыОбъектовМетаданных.ДобавлениеОбработчиковОбновления(Обработчики);
	Справочники.ИнструментыСистемы.ДобавлениеОбработчиковОбновления(Обработчики);
	Справочники.ГруппыДоступа.ДобавлениеОбработчиковОбновления(Обработчики);
	Справочники.СтатусыОбъектов.ДобавлениеОбработчиковОбновления(Обработчики);
	Справочники.НазначенияЗадач.ДобавлениеОбработчиковОбновления(Обработчики);
	Справочники.ДействияПриСменеСтатуса.ДобавлениеОбработчиковОбновления(Обработчики);
	Справочники.Процессы.ДобавлениеОбработчиковОбновления(Обработчики);
	Справочники.ВидыДеятельности.ДобавлениеОбработчиковОбновления(Обработчики);
	Справочники.СлужебныеФоновыеЗадания.ДобавлениеОбработчиковОбновления(Обработчики);
	Справочники.КлассификаторИспользованияРабочегоВремени.ДобавлениеОбработчиковОбновления(Обработчики);
	Справочники.СерьезностьОшибок.ДобавлениеОбработчиковОбновления(Обработчики);
	
	ПланыВидовХарактеристик.ВидыДополнительныхРеквизитов.ДобавлениеОбработчиковОбновления(Обработчики);
	ПланыВидовХарактеристик.ВидыНастроекПользователя.ДобавлениеОбработчиковОбновления(Обработчики);	
	ПланыВидовХарактеристик.ВидыНастроекФилиалов.ДобавлениеОбработчиковОбновления(Обработчики);	
	
	РегистрыСведений.НастройкиПереходаСтатусовОбъектов.ДобавлениеОбработчиковОбновления(Обработчики);
	РегистрыСведений.СвязьОбъектовИРолей.ДобавлениеОбработчиковОбновления(Обработчики);
	РегистрыСведений.ПроизводственныйКалендарь.ДобавлениеОбработчиковОбновления(Обработчики);
	
	Справочники.ТипыОбъектовВладельцев.ДобавлениеОбработчиковОбновления(Обработчики);

	Возврат Обработчики;
	
КонецФункции

#КонецОбласти

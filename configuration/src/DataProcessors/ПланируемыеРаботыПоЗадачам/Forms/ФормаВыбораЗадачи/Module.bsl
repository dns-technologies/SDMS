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
	
	РегистрыСведений.ОтслеживаниеИспользованияФункциональности.ОткрытиеФормы(ЭтотОбъект.ИмяФормы);
	
	Заголовок = СтрШаблон("Добавление задачи на %1", Параметры.Дата);
	ДобавленныеЗадачи = Параметры.ДобавленныеЗадачи;
	Исполнитель = ПараметрыСеанса.ТекущийПользователь;
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	Пользователи.Ссылка КАК Ссылка,
	|	Пользователи.ФИО КАК ФИО
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|ГДЕ
	|	Пользователи.Филиал В(&ФилиалыПользователя)
	|	И НЕ Пользователи.Недействителен
	|	И НЕ Пользователи.ПометкаУдаления
	|
	|УПОРЯДОЧИТЬ ПО
	|	ФИО";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ФилиалыПользователя", ПараметрыСеанса.СвязанныеФилиалы);
	
	ВыборкаСотрудников = Запрос.Выполнить().Выбрать();
	
	Пока ВыборкаСотрудников.Следующий() Цикл
		Элементы.Исполнитель.СписокВыбора.Добавить(ВыборкаСотрудников.Ссылка, ВыборкаСотрудников.ФИО);
	КонецЦикла;
	
	СписокЗадач = ПолучитьСписокЗадач(ДобавленныеЗадачи, Исполнитель);
	ЗаполнитьСписокЗадач(ДоступныеЗадачи, СписокЗадач, Исполнитель);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ЗадачиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ВыбратьЗадачу();
	
КонецПроцедуры

&НаКлиенте
Процедура ИсполнительПриИзменении(Элемент)
	
	СписокЗадач = ПолучитьСписокЗадач(ДобавленныеЗадачи, Исполнитель);
	ЗаполнитьСписокЗадач(ДоступныеЗадачи, СписокЗадач, Исполнитель);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКоманд

&НаКлиенте
Процедура Выбрать(Команда)
	
	ВыбратьЗадачу();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыбратьЗадачу()
	
	ТекущиеДанные = Элементы.ДоступныеЗадачи.ТекущиеДанные;
	
	Если ТекущиеДанные <> Неопределено И ЗначениеЗаполнено(ТекущиеДанные.Задача) Тогда
		ПараметрЗакрытия = Новый Структура("Задача, Номер, Наименование, Представление");
		ЗаполнитьЗначенияСвойств(ПараметрЗакрытия, ТекущиеДанные);
		Закрыть(ПараметрЗакрытия);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьСписокЗадач(Дерево, СписокЗадач, Исполнитель)
	
	ЭлементыДерева = Дерево.ПолучитьЭлементы();
	ЭлементыДерева.Очистить();
	
	Если ЗначениеЗаполнено(Исполнитель) Тогда
		Если СписокЗадач.Количество() > 0 Тогда
			Данные = СписокЗадач.Получить(0);
			
			Для Каждого ДанныеЗадачи Из Данные.ПодчиненныеСтроки Цикл
				НоваяЗадача = ЭлементыДерева.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяЗадача, ДанныеЗадачи);
			КонецЦикла;
		КонецЕсли; 
	Иначе
		Для Каждого Данные Из СписокЗадач Цикл
			НоваяСтрока = ЭлементыДерева.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, Данные);
			
			Для Каждого ДанныеЗадачи Из Данные.ПодчиненныеСтроки Цикл
				НоваяЗадача = НоваяСтрока.ПолучитьЭлементы().Добавить();
				ЗаполнитьЗначенияСвойств(НоваяЗадача, ДанныеЗадачи);
			КонецЦикла;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьСписокЗадач(Знач ДобавленныеЗадачи, Знач Исполнитель)
	
	ДоступныеЗадачи = Новый Массив;
	ИндексКартинки_Группа = Справочники.СтатусыОбъектов.ИндексКартинкиГруппа();
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	Задача.Ссылка КАК Ссылка,
	|	Задача.Наименование КАК Наименование,
	|	Задача.Номер КАК Номер,
	|	Задача.Назначена КАК Исполнитель,
	|	Задача.Статус КАК Статус,
	|	Пользователи.ФИО КАК ФИО
	|ПОМЕСТИТЬ ОтобранныеЗадачи
	|ИЗ
	|	Документ.Задача КАК Задача
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Пользователи КАК Пользователи
	|		ПО Задача.Назначена = Пользователи.Ссылка
	|ГДЕ
	|	Пользователи.Филиал В(&ФилиалыПользователя)
	|	И НЕ Задача.Статус В (ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Решен), ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Отклонен))
	|{ГДЕ
	|	Задача.Назначена КАК Исполнитель}
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	Задача.Ссылка,
	|	Задача.Наименование,
	|	Задача.Номер,
	|	Задача.Назначена,
	|	Задача.Статус,
	|	ЕСТЬNULL(Пользователи.ФИО, """")
	|ИЗ
	|	Документ.Задача КАК Задача
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Пользователи КАК Пользователи
	|		ПО Задача.Назначена = Пользователи.Ссылка
	|ГДЕ
	|	Задача.Филиал В(&ФилиалыПользователя)
	|	И НЕ Задача.Статус В (ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Решен), ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Отклонен))
	|{ГДЕ
	|	Задача.Назначена КАК Исполнитель}
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ОтобранныеЗадачи.Ссылка КАК Задача,
	|	ПРЕДСТАВЛЕНИЕ(ОтобранныеЗадачи.Ссылка) КАК Представление,
	|	ОтобранныеЗадачи.Наименование КАК Наименование,
	|	ОтобранныеЗадачи.Номер КАК Номер,
	|	ОтобранныеЗадачи.Исполнитель КАК Исполнитель,
	|	СтатусыОбъектов.ИндексКартинки КАК ИндексКартинки,
	|	ОтобранныеЗадачи.ФИО КАК ИсполнительПредставление
	|ИЗ
	|	ОтобранныеЗадачи КАК ОтобранныеЗадачи
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтатусыОбъектов КАК СтатусыОбъектов
	|		ПО ОтобранныеЗадачи.Статус = СтатусыОбъектов.Ссылка
	|ГДЕ
	|	НЕ ОтобранныеЗадачи.Ссылка В (&ДобавленныеЗадачи)
	|
	|УПОРЯДОЧИТЬ ПО
	|	ИсполнительПредставление
	|ИТОГИ
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Задача),
	|	МАКСИМУМ(ИсполнительПредставление)
	|ПО
	|	Исполнитель";
	
	ПостроительЗапроса = Новый ПостроительЗапроса(ТекстЗапроса);
	ПостроительЗапроса.Параметры.Вставить("ФилиалыПользователя", ПараметрыСеанса.СвязанныеФилиалы);
	ПостроительЗапроса.Параметры.Вставить("ДобавленныеЗадачи", ДобавленныеЗадачи);
	
	Если ЗначениеЗаполнено(Исполнитель) Тогда
		ЭлементОтбора = ПостроительЗапроса.Отбор.Добавить("Исполнитель");
		ЭлементОтбора.ВидСравнения = ВидСравнения.Равно;
		ЭлементОтбора.Значение = Исполнитель;
		ЭлементОтбора.Использование = Истина;
	КонецЕсли;
	
	ПостроительЗапроса.Выполнить();
	РезультатЗапроса = ПостроительЗапроса.Результат;
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		ВыборкаПользователей = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		
		Пока ВыборкаПользователей.Следующий() Цикл
			Данные = Новый Структура;
			
			Если ЗначениеЗаполнено(ВыборкаПользователей.Исполнитель) Тогда
				ПредставлениеСотрудник = ВыборкаПользователей.ИсполнительПредставление;
			Иначе
				ПредставлениеСотрудник = "Не назначена";
			КонецЕсли;
			
			КоличествоЗадач = СтрокаСЧислом("; %1 задача; ; %1 задачи; %1 задач; %1 задачи", 
				ВыборкаПользователей.Задача, ВидЧисловогоЗначения.Количественное);
			
			Данные.Вставить("Исполнитель", ВыборкаПользователей.Исполнитель);
			Данные.Вставить("Представление", СтрШаблон("%1 | %2", ПредставлениеСотрудник, КоличествоЗадач));
			Данные.Вставить("ИндексКартинки", ИндексКартинки_Группа);
			
			ПодчиненныеСтроки = Новый Массив;
			
			Выборка = ВыборкаПользователей.Выбрать();
			Пока Выборка.Следующий() Цикл
				ДанныеЗадачи = Новый Структура("Задача, Номер, Наименование, Исполнитель, Представление, ИндексКартинки,");
				ЗаполнитьЗначенияСвойств(ДанныеЗадачи, Выборка);
				ПодчиненныеСтроки.Добавить(ДанныеЗадачи);
			КонецЦикла;
			
			Данные.Вставить("ПодчиненныеСтроки", ПодчиненныеСтроки);
			
			ДоступныеЗадачи.Добавить(Данные);
		КонецЦикла;
	КонецЕсли;
	
	Возврат ДоступныеЗадачи;
	
КонецФункции

#КонецОбласти

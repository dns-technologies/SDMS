///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Добавляет обработчики обновления
//
// Параметры:
//  Обработчики	 - ТаблицаЗначений	 - см. ПриложениеВызовСервера.ПолучитьОбработчикиДанных
//
Процедура ДобавлениеОбработчиковОбновления(Обработчики) Экспорт     
	
	Обработчик = Обработчики.Добавить();
	Обработчик.Версия = "*";
	Обработчик.Процедура = "РегистрыСведений.СвязьОбъектовИРолей.ПроверитьПредопределенныеНастройки";
	
КонецПроцедуры

// Проверяет предопределенные настройки
//
Процедура ПроверитьПредопределенныеНастройки() Экспорт                              
	
	ИмяМетода = "БезопасностьПереопределяемый.ПравоНастройкаОграниченногоПросмотра";
	МетодНастройки = "БезопасностьПереопределяемый.ПрименитьПравоНастройкаОграниченногоПросмотра";
	ЗаполнитьНастройку("ОбщаяФорма.НастройкаПравОбъектов", "НастройкаОграниченногоПросмотра", 
		Перечисления.ВидыПравДоступа.Разрешено, ИмяМетода, МетодНастройки);
		
	ИмяМетода = "БезопасностьПереопределяемый.ПравоРазрешитьОткрытиеОграниченныйПросмотр_Заявка";
	ЗаполнитьНастройку("Документ.ЗаявкаНаРазработку.Форма.ФормаДокумента", "ОграниченныйПросмотр", 
		Перечисления.ВидыПравДоступа.Разрешено, ИмяМетода);
		
	ИмяМетода = "БезопасностьПереопределяемый.ПравоРазрешитьОткрытиеОграниченныйПросмотр_Задача";
	ЗаполнитьНастройку("Документ.Задача.Форма.ФормаДокумента", "ОграниченныйПросмотр", 
		Перечисления.ВидыПравДоступа.Разрешено, ИмяМетода); 
		
	ИмяМетода = "БезопасностьПереопределяемый.ПравоОтклоненияЗаявки";
	МетодНастройки = "БезопасностьПереопределяемый.ПрименитьПравоОтклоненияЗаявки";
	ЗаполнитьНастройку("Документ.ЗаявкаНаРазработку.Форма.ФормаДокумента", "ОтклонениеЗаявки", 
		Перечисления.ВидыПравДоступа.Запрещено, ИмяМетода, МетодНастройки);
		
	ИмяМетода = "БезопасностьПереопределяемый.ПравоДелегированияЗаявки";
	МетодНастройки = "БезопасностьПереопределяемый.ПрименитьПравоДелегированияЗаявки";
	ЗаполнитьНастройку("Документ.ЗаявкаНаРазработку.Форма.ФормаДокумента", "ДелегированиеЗаявки", 
		Перечисления.ВидыПравДоступа.Запрещено, ИмяМетода, МетодНастройки);	
		
	ИмяМетода = "БезопасностьПереопределяемый.ПравоУстановитьОграниченныйПросмотр";
	МетодНастройки = "БезопасностьПереопределяемый.ПрименитьПравоУстановкиОграниченногоПросмотра";
	ЗаполнитьНастройку("Документ.ЗаявкаНаРазработку.Форма.ФормаДокумента", "УстановитьОграниченныйПросмотр", 
		Перечисления.ВидыПравДоступа.Запрещено, ИмяМетода, МетодНастройки);
		
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции  

Процедура ЗаполнитьНастройку(Объект, Роль, ЗначениеПоУмолчанию, ИмяМетода, ИмяМетодаНастройки = "", РассчитыватьПраво = Истина);
	
	ОбъектМетаданных = Справочники.ИдентификаторыОбъектовМетаданных.НайтиПоРеквизиту("ПолноеИмяФормы", Объект); 
	
	Если НЕ ЗначениеЗаполнено(ОбъектМетаданных) Тогда  
		Сообщение = НСтр("ru = 'Элемент ИдентификаторыОбъектовМетаданных ""%Параметр%"" не найден.'");
		Сообщение = СтрЗаменить(Сообщение, "%Параметр%", Объект);
		ВызватьИсключение Сообщение;
	КонецЕсли;
	
	Попытка
		ПрограммнаяРоль = ОбщегоНазначения.ПредопределенныйЭлемент("Справочник.ПрограммныеРоли." + Роль);
	Исключение
		Сообщение = НСтр("ru = 'Предопределенный элемент ""%Параметр%"" не найден.'");
		Сообщение = СтрЗаменить(Сообщение, "%Параметр%", "Справочник.ПрограммныеРоли." + Роль);
		ВызватьИсключение Сообщение;
	КонецПопытки;
	
	Набор = СоздатьНаборЗаписей();
	Набор.Отбор.Объект.Установить(ОбъектМетаданных);
	Набор.Отбор.Роль.Установить(ПрограммнаяРоль);
	Набор.Прочитать();
	
	Если Набор.Количество() = 0 Тогда	
		Запись = Набор.Добавить();
		Запись.Объект = ОбъектМетаданных;
		Запись.Роль = ПрограммнаяРоль;
		Запись.ЗначениеПоУмолчанию = ЗначениеПоУмолчанию;
		Запись.ИмяМетода = ИмяМетода;
		Запись.ИмяМетодаНастройки = ИмяМетодаНастройки;
		Запись.РассчитыватьПраво = РассчитыватьПраво;      
		Запись.Использование = Истина;
		Набор.Записать();               
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

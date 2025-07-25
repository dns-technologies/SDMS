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
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	ЗаполнитьСтарыеЦеныУслуг();
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Ключ.Пустая() Тогда
		ОбщегоНазначения.ЗаполнитьОбъектПервоначальнымиДанными(Объект);	
		Объект.ДатаПримененияЦены = НачалоДня(ТекущаяДатаСеанса());
	КонецЕсли;
	
	НастроитьТаблицуЦен();

КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	ЗаполнитьСтарыеЦеныУслуг();

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура АвторНажатие(Элемент, СтандартнаяОбработка)
	
	ИнтерфейсПриложенияКлиент.ОткрытьИнформациюОПользователе(ЭтотОбъект, Объект.Автор, СтандартнаяОбработка);

КонецПроцедуры

&НаКлиенте
Процедура ДатаПримененияЦеныПриИзменении(Элемент)
	
	ЗаполнитьСтарыеЦеныУслуг();

КонецПроцедуры

&НаКлиенте
Процедура ЮридическоеЛицоПриИзменении(Элемент)
	
	НастроитьТаблицуЦен();
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий таблицы "Услуги"

&НаКлиенте
Процедура УслугиУслугаПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.Услуги.ТекущиеДанные;	
	ТекущиеДанные.СтараяЦена = ТекущаяЦенаУслуги(ТекущиеДанные.Услуга, Объект.ДатаПримененияЦены, Объект.ЮридическоеЛицо);
		
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКоманд

&НаКлиенте
Процедура ДобавитьНесколько(Команда)
	
	ВыбранныеУслуги = Новый Массив;
	
	Для Каждого Строка Из Объект.Услуги Цикл
		ВыбранныеУслуги.Добавить(Строка.Услуга);
	КонецЦикла;

	ПараметрыОткрытия = Новый Структура("ВыбранныеУслуги", ВыбранныеУслуги);
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьВыборУслуг", ЭтотОбъект);
	
	ОткрытьФорму("Справочник.Услуги.Форма.МножественныйВыбор", ПараметрыОткрытия, ЭтотОбъект, , , , ОписаниеОповещения);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьСтарыеЦеныУслуг()
	
	СписокУслуг = Объект.Услуги.Выгрузить().ВыгрузитьКолонку("Услуга");
	Граница = Новый Граница(Объект.ДатаПримененияЦены, ВидГраницы.Исключая);
	
	СтоимостьУслуг = РегистрыСведений.СтоимостьУслуг.ПолучитьСтоимость(СписокУслуг, Объект.ЮридическоеЛицо, Граница);
	
	Если СтоимостьУслуг.Количество() <> 0 Тогда
		Для Каждого Строка Из Объект.Услуги Цикл
			Строка.СтараяЦена = СтоимостьУслуг.Получить(Строка.Услуга);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ТекущаяЦенаУслуги(Знач Услуга, Знач Дата, Знач ЮридическоеЛицо)
	
	Граница = Новый Граница(Дата, ВидГраницы.Исключая);
	Цена = РегистрыСведений.СтоимостьУслуг.ПолучитьСтоимость(Услуга, ЮридическоеЛицо, Граница);
	
	Возврат Цена;

КонецФункции

&НаСервере
Процедура НастроитьТаблицуЦен()
	
	Если ЗначениеЗаполнено(Объект.ЮридическоеЛицо) Тогда
		СтоимостьВключаетНДС = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.ЮридическоеЛицо, "СтоимостьУслугиВключаетНДС");
		Элементы.УслугиЦена.Заголовок = ?(СтоимостьВключаетНДС, "Новая цена (с НДС)", "Новая цена (без НДС)");
	Иначе
		Элементы.УслугиЦена.Заголовок = "Новая цена (с НДС)";
	КонецЕсли;
	
	ЗаполнитьСтарыеЦеныУслуг();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьВыборУслуг(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого Строка Из Объект.Услуги Цикл
		Услуга = Результат.НайтиПоЗначению(Строка.Услуга);
		Если Услуга = Неопределено Тогда
			Объект.Услуги.Удалить(Строка);
		КонецЕсли;
	КонецЦикла;
		
	Для Каждого ЭлементКоллекции Из Результат Цикл
		ПараметрыОтбора = Новый Структура("Услуга", ЭлементКоллекции.Значение);
		Строки = Объект.Услуги.НайтиСтроки(ПараметрыОтбора);
			
		Если Строки.Количество() = 0 Тогда
			НоваяСтрока = Объект.Услуги.Добавить();
			НоваяСтрока.Услуга = ЭлементКоллекции.Значение;
			НоваяСтрока.СтараяЦена = ТекущаяЦенаУслуги(ЭлементКоллекции.Значение, Объект.ДатаПримененияЦены, Объект.ЮридическоеЛицо);
		КонецЕсли;
	КонецЦикла; 
	
КонецПроцедуры	

#КонецОбласти

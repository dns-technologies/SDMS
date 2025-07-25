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
	
	Если Параметры.Свойство("Задача") Тогда
		Задача = Параметры.Задача;
	КонецЕсли;
	
	Если Параметры.Свойство("СтруктураЗаписи") Тогда
		Данные = Параметры.СтруктураЗаписи;
		Период = Данные.Период;
		СтарыйПериод = Данные.Период;
		ДатаИсторииХранилища = Данные.ДатаИсторииХранилища;
		ДатаДобавления = Данные.ДатаДобавления;
		Автор = Данные.Автор;
		УведомленияОтправлены = Данные.УведомленияОтправлены;
	Иначе
		ДатаДобавления = ТекущаяДатаСеанса();
		Автор = ПараметрыСеанса.ТекущийПользователь;
		УведомленияОтправлены = Истина;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура АвторОткрытие(Элемент, СтандартнаяОбработка)
	
	ИнтерфейсПриложенияКлиент.ОткрытьИнформациюОПользователе(ЭтотОбъект, Автор, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ПериодПриИзменении(Элемент)
	
	ДатаИсторииХранилища = Период;
		
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Сохранить(Команда)
	
	Если ЗначениеЗаполнено(Период) Тогда	
		СохранитьНаСервере();
		Закрыть(Истина);
	Иначе
		ПоказатьПредупреждение(, "Период является обязательным для заполнения.");
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура СохранитьНаСервере()
	
	Если ЗначениеЗаполнено(СтарыйПериод) Тогда
		РегистрыСведений.ИсторияПубликацииЗадач.Удалить(Задача, СтарыйПериод);	
	КонецЕсли;
	
	РегистрыСведений.ИсторияПубликацииЗадач.Добавить(Задача, Период, Период, Истина);
	
КонецПроцедуры

#КонецОбласти

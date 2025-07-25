///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер ИЛИ ТолстыйКлиентОбычноеПриложение ИЛИ ВнешнееСоединение Тогда
	
#Область ОписаниеПеременных

// Хранит состояние реквизита "Куратор" до записи
Перем КураторСтароеЗначение;

#КонецОбласти
		
#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
		
	Если ЭтоНовый() Тогда
		ЗаполнитьСлужебныеРеквизитыНовогоОбъекта();
	КонецЕсли;
	
	СформироватьСтроковоеПредставлениеОтветственных();
	
	КураторСтароеЗначение = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, "Куратор");
	
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	
	Автор = Неопределено;
	ДатаСоздания = Неопределено;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция КураторВДругихГруппахЗаказчиков(Знач Куратор)
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ГруппыЗаказчиковНаправлений.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ГруппыЗаказчиковНаправлений КАК ГруппыЗаказчиковНаправлений
	|ГДЕ
	|	ГруппыЗаказчиковНаправлений.Куратор = &Куратор";
	
	Запрос.УстановитьПараметр("Куратор", Куратор);
	
	Результат = Запрос.Выполнить();
	
	Возврат НЕ Результат.Пустой();
	
КонецФункции

Процедура ЗаполнитьСлужебныеРеквизитыНовогоОбъекта()
	
	Автор = ПараметрыСеанса.ТекущийПользователь;
	ДатаСоздания = ТекущаяДатаСеанса();
	
КонецПроцедуры

Процедура СформироватьСтроковоеПредставлениеОтветственных()
	
	ПараметрыОтбора = Новый Структура("Ответственный", Истина);
	НайденныеСтроки = Заказчики.Выгрузить(ПараметрыОтбора, "Пользователь");
	
	Если НайденныеСтроки.Количество() > 0 Тогда
		Ответственные = НайденныеСтроки.ВыгрузитьКолонку("Пользователь");
		
		ПредставлениеОтветственных = СтрСоединить(Ответственные, ", ");
	Иначе
		ПредставлениеОтветственных = "";
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли

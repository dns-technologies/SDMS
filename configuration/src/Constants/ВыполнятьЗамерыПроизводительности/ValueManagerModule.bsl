///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	РегЗадание = РегламентныеЗадания.НайтиПредопределенное(Метаданные.РегламентныеЗадания.ОчисткаЗамеровВремени);
	
	Если РегЗадание <> Неопределено Тогда
		//РегЗадание.Использование = ЭтотОбъект.Значение;
		РегЗадание.Использование = Ложь;
		РегЗадание.Записать();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли

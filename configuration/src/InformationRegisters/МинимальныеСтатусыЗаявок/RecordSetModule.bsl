///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер ИЛИ ВнешнееСоединение ИЛИ ТолстыйКлиентОбычноеПриложение Тогда
	
#Область ОписаниеПеременных

// Признак сохранения минимального статуса в периодический регистр сведений 
// ИсторияМинимальныхСтатусовЗаявок.
Перем СохранитьИсторию Экспорт;

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПриЗаписи(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если ЭтотОбъект.Количество() > 0 Тогда
		Если СохранитьИсторию = Истина Тогда
			
			// Получение сдвига времени. Используется при "теневом" переводе задач по статусам
			Если ДополнительныеСвойства.Свойство("СдвигВремени") Тогда
				СдвигВремени = ДополнительныеСвойства.СдвигВремени;
			Иначе
				СдвигВремени = 0;
			КонецЕсли;
			
			Для Каждого ЗаписьРегистра Из ЭтотОбъект Цикл
				ИнтеграцияДополнительныхПодсистем.АктуализироватьВTrello(ЗаписьРегистра.Заявка);
				
				РегистрыСведений.ИсторияМинимальныхСтатусовЗаявок.Добавить(ЗаписьРегистра.Заявка,
					ЗаписьРегистра.Статус, СдвигВремени);
			КонецЦикла;
		КонецЕсли;	
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область Инициализация

// По умолчанию история минимального статуса сохраняется
СохранитьИсторию = Истина;

#КонецОбласти

#КонецЕсли

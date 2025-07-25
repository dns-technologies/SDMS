///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Элементы.ТекстВопроса.Заголовок = Параметры.ТекстВопроса;
	
	Для Каждого Вариант Из Параметры.Варианты Цикл
		ИмяВарианта = "Вариант" + Вариант.Значение;
		
		Команда = Команды.Добавить(ИмяВарианта);
		Команда.Действие = "ОбработчикОтветаНаВопрос";
		
		Кнопка = Элементы.Добавить(ИмяВарианта, Тип("КнопкаФормы"), Элементы.ФормаКоманднаяПанель);
		Кнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
		Кнопка.Заголовок = Вариант.Представление;
		Кнопка.ИмяКоманды = ИмяВарианта;
	КонецЦикла; 
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработчикОтветаНаВопрос(Команда)
	
	Результат = СтрЗаменить(Команда.Имя, "Вариант", "");
	Ответ = Число(Результат);
	Закрыть(Ответ);
	
КонецПроцедуры

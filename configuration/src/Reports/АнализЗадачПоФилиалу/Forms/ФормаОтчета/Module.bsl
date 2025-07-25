///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем НастройкиПользователя; // Хранит настройки пользователя

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Ключи = ПолучитьКлючиНастроек();
	НастройкиПользователя = ОбщегоНазначенияВызовСервера.ЗагрузитьНастройкиДанныхФормы(Ключи.Объект, Ключи.Настройка);
	
	Если НастройкиПользователя = Неопределено Тогда
		НастройкиПользователя = Новый Структура;
		НастройкиПользователя.Вставить("Направление");
		НастройкиПользователя.Вставить("Филиал");
		НастройкиПользователя.Вставить("Период");
		НастройкиПользователя.Вставить("КоличествоЧеловек");
		НастройкиПользователя.Вставить("ПоинтыНаЧеловекаВДень", 2);
		НастройкиПользователя.Вставить("ЧасРасчета", 19);
	КонецЕсли;
	
	АдресХранилища = ПоместитьВоВременноеХранилище(НастройкиПользователя, УникальныйИдентификатор);
	
	СформироватьОтчет(НастройкиПользователя);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	НастройкиПользователя = ПолучитьИзВременногоХранилища(АдресХранилища);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ДиаграммаСтатусыВыбор(Элемент, ЗначениеДиаграммы, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СтатусНазвание = ТРег(ЗначениеДиаграммы.Серия.Текст);
	СтатусНазвание = СтрЗаменить(СтатусНазвание, " ", "");
	День = ЗначениеДиаграммы.Точка.Значение + НастройкиПользователя.ЧасРасчета * 60 * 60;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("День", День);
	ПараметрыФормы.Вставить("Статус", СтатусНазвание);
	ПараметрыФормы.Вставить("Филиал", НастройкиПользователя.Филиал);
	ПараметрыФормы.Вставить("ДатаНачала", НачалоДня(НастройкиПользователя.Период.ДатаНачала));

	ОткрытьФорму("Отчет.АнализЗадачПоФилиалу.Форма.ФормаРасшифровкиПоСтатусу", ПараметрыФормы, , Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура СтатусыЗадачВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
		
	СтандартнаяОбработка = Ложь;
	Данные = Элементы.СтатусыЗадач.ТекущиеДанные;
	СтатусНазвание = СтрЗаменить(Поле.Имя, "СтатусыЗадач", "");
	День = Данные.Дата + НастройкиПользователя.ЧасРасчета * 60 * 60;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("День", День);
	ПараметрыФормы.Вставить("Статус", СтатусНазвание);
	ПараметрыФормы.Вставить("Филиал", НастройкиПользователя.Филиал);
	ПараметрыФормы.Вставить("ДатаНачала", НачалоДня(НастройкиПользователя.Период.ДатаНачала));

	ОткрытьФорму("Отчет.АнализЗадачПоФилиалу.Форма.ФормаРасшифровкиПоСтатусу", ПараметрыФормы, , Истина);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКоманд

&НаКлиенте
Процедура Настройки(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьЗакрытиеФормыНастроек", ЭтотОбъект);
	ОткрытьФорму("Отчет.АнализЗадачПоФилиалу.Форма.НастройкиОтчета", НастройкиПользователя,
		ЭтотОбъект, , , , ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	
	СформироватьОтчет(НастройкиПользователя);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ОбработатьЗакрытиеФормыНастроек(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> Неопределено Тогда
		НастройкиПользователя = Результат;
		СформироватьОтчет(НастройкиПользователя);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьКлючиНастроек()
	
	КлючиНастроек = Новый Структура;
	КлючиНастроек.Вставить("Объект", "Отчет.АнализРаботыКомандыSITE");
	КлючиНастроек.Вставить("Настройка", "НастройкиПользователя");
	
	Возврат КлючиНастроек;
	
КонецФункции

&НаСервереБезКонтекста
Процедура СохранитьНастройкиПользователя(Знач Настройки)
	
	Ключи = ПолучитьКлючиНастроек();
	ОбщегоНазначенияВызовСервера.СохранитьНастройкиДанныхФормы(Ключи.Объект, Ключи.Настройка, Настройки);
	
КонецПроцедуры

&НаСервере
Процедура СформироватьОтчет(Знач Настройки)
	
	СохранитьНастройкиПользователя(Настройки);
	
	Поинты.Очистить();
	СтатусыЗадач.Очистить();
	ДиаграммаПоинты.Очистить();
	ДиаграммаСтатусы.Очистить();
	ДиаграммаПоинтыНаЧеловека.Очистить();
	
	Если НЕ (ЗначениеЗаполнено(Настройки.Период) И Настройки.Свойство("Филиал") И ЗначениеЗаполнено(Настройки.Филиал)) Тогда
		Возврат;
	КонецЕсли;
	
	ТекущаяДата = ТекущаяДатаСеанса();
	
#Область ТекстЗапроса
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ПроизводственныйКалендарь.ДатаКалендаря КАК ДатаКалендаря,
	|	ДОБАВИТЬКДАТЕ(НАЧАЛОПЕРИОДА(ПроизводственныйКалендарь.ДатаКалендаря, ДЕНЬ), ЧАС, &ЧасРасчета) КАК ДатаВремяУчета
	|ПОМЕСТИТЬ РабочиеДниКалендаря
	|ИЗ
	|	РегистрСведений.ПроизводственныйКалендарь КАК ПроизводственныйКалендарь
	|ГДЕ
	|	ПроизводственныйКалендарь.ДатаКалендаря МЕЖДУ НАЧАЛОПЕРИОДА(&ДатаНачала, ДЕНЬ) И КОНЕЦПЕРИОДА(&ДатаОкончания, ДЕНЬ)
	|	И ПроизводственныйКалендарь.ВидДня <> ЗНАЧЕНИЕ(Перечисление.ВидыДнейПроизводственногоКалендаря.Выходной)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	РабочиеДниКалендаря.ДатаКалендаря КАК ДатаКалендаря,
	|	РабочиеДниКалендаря.ДатаВремяУчета КАК ДатаВремяУчета,
	|	ВЫБОР
	|		КОГДА РабочиеДниКалендаря.ДатаКалендаря = НАЧАЛОПЕРИОДА(&ТекущаяДата, ДЕНЬ)
	|				И ЧАС(&ТекущаяДата) < &ЧасРасчета
	|			ТОГДА ИСТИНА
	|		КОГДА РабочиеДниКалендаря.ДатаВремяУчета <= &ТекущаяДата
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК ДатаНаступила
	|ПОМЕСТИТЬ РабочиеДни
	|ИЗ
	|	РабочиеДниКалендаря КАК РабочиеДниКалендаря
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СтатусыОбъектов.Ссылка КАК Статус,
	|	СтатусыОбъектов.ИмяПредопределенныхДанных КАК ИмяКолонки
	|ПОМЕСТИТЬ ВыбранныеСтатусы
	|ИЗ
	|	Справочник.СтатусыОбъектов КАК СтатусыОбъектов
	|ГДЕ
	|	СтатусыОбъектов.Ссылка В (ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Решен), ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Приостановлен), ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Тестирование), ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.CodeReview), ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.ВРаботе), ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.ВРеализацию))
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СвойстваЗадачСрезПоследних.Объект КАК Задача
	|ПОМЕСТИТЬ ОтобранныеЗадачи
	|ИЗ
	|	РегистрСведений.СвойстваЗадач.СрезПоследних(&ДатаНачала, ) КАК СвойстваЗадачСрезПоследних
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Задача КАК Задача
	|		ПО СвойстваЗадачСрезПоследних.Объект = Задача.Ссылка
	|			И (Задача.Филиал = &Филиал)
	|ГДЕ
	|	НЕ СвойстваЗадачСрезПоследних.Статус В (ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Решен), ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Отклонен))
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ДокументЗадача.Ссылка
	|ИЗ
	|	Документ.Задача КАК ДокументЗадача
	|ГДЕ
	|	ДокументЗадача.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания
	|	И ДокументЗадача.Филиал = &Филиал
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СвойстваЗадачСрезПоследних.Объект КАК Объект,
	|	СвойстваЗадачСрезПоследних.Статус КАК Статус,
	|	СвойстваЗадачСрезПоследних.Период КАК Период
	|ПОМЕСТИТЬ СтатусыЗадачПоПериодам
	|ИЗ
	|	РегистрСведений.СвойстваЗадач.СрезПоследних(
	|			&ДатаНачала,
	|			Объект В
	|				(ВЫБРАТЬ
	|					ОтобранныеЗадачи.Задача
	|				ИЗ
	|					ОтобранныеЗадачи)) КАК СвойстваЗадачСрезПоследних
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	СвойстваЗадач.Объект,
	|	СвойстваЗадач.Статус,
	|	СвойстваЗадач.Период
	|ИЗ
	|	ОтобранныеЗадачи КАК ОтобранныеЗадачи
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.СвойстваЗадач КАК СвойстваЗадач
	|		ПО ОтобранныеЗадачи.Задача = СвойстваЗадач.Объект
	|ГДЕ
	|	СвойстваЗадач.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СтатусыЗадачПоПериодам1.Объект КАК Объект,
	|	СтатусыЗадачПоПериодам1.Статус КАК Статус,
	|	СтатусыЗадачПоПериодам1.Период КАК ДатаНачала,
	|	ЕСТЬNULL(МИНИМУМ(СтатусыЗадачПоПериодам2.Период), &ДатаОкончания) КАК ДатаОкончания
	|ПОМЕСТИТЬ ДатаОкончанияНахожденияВСтатусе
	|ИЗ
	|	СтатусыЗадачПоПериодам КАК СтатусыЗадачПоПериодам1
	|		ЛЕВОЕ СОЕДИНЕНИЕ СтатусыЗадачПоПериодам КАК СтатусыЗадачПоПериодам2
	|		ПО СтатусыЗадачПоПериодам1.Объект = СтатусыЗадачПоПериодам2.Объект
	|			И СтатусыЗадачПоПериодам1.Статус <> СтатусыЗадачПоПериодам2.Статус
	|			И СтатусыЗадачПоПериодам1.Период < СтатусыЗадачПоПериодам2.Период
	|
	|СГРУППИРОВАТЬ ПО
	|	СтатусыЗадачПоПериодам1.Объект,
	|	СтатусыЗадачПоПериодам1.Статус,
	|	СтатусыЗадачПоПериодам1.Период
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДатаОкончанияНахожденияВСтатусе.Объект КАК Объект,
	|	ДатаОкончанияНахожденияВСтатусе.Статус КАК Статус,
	|	МИНИМУМ(ДатаОкончанияНахожденияВСтатусе.ДатаНачала) КАК ДатаНачала,
	|	ДатаОкончанияНахожденияВСтатусе.ДатаОкончания КАК ДатаОкончания
	|ПОМЕСТИТЬ ПереходыЗадачПоСтатусамЗаПериод
	|ИЗ
	|	ДатаОкончанияНахожденияВСтатусе КАК ДатаОкончанияНахожденияВСтатусе
	|
	|СГРУППИРОВАТЬ ПО
	|	ДатаОкончанияНахожденияВСтатусе.Объект,
	|	ДатаОкончанияНахожденияВСтатусе.Статус,
	|	ДатаОкончанияНахожденияВСтатусе.ДатаОкончания
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	РабочиеДни.ДатаКалендаря КАК ДатаКалендаря,
	|	ПереходыЗадачПоСтатусамЗаПериод.Статус КАК Статус,
	|	ПереходыЗадачПоСтатусамЗаПериод.Объект КАК Объект,
	|	ПереходыЗадачПоСтатусамЗаПериод.ДатаНачала КАК ДатаПерехода,
	|	РабочиеДни.ДатаВремяУчета КАК ДатаВремяУчета
	|ПОМЕСТИТЬ СтатусыОбъектовПоДням
	|ИЗ
	|	РабочиеДни КАК РабочиеДни
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ПереходыЗадачПоСтатусамЗаПериод КАК ПереходыЗадачПоСтатусамЗаПериод
	|		ПО (РабочиеДни.ДатаВремяУчета МЕЖДУ ПереходыЗадачПоСтатусамЗаПериод.ДатаНачала И ПереходыЗадачПоСтатусамЗаПериод.ДатаОкончания)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	СтатусыОбъектовПоДням.Объект КАК Объект,
	|	ЕСТЬNULL(ПланируемыеТрудозатраты.Трудозатраты, 0) / 4 КАК План
	|ПОМЕСТИТЬ ПланРешенныхЗадач
	|ИЗ
	|	СтатусыОбъектовПоДням КАК СтатусыОбъектовПоДням
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПланируемыеТрудозатраты КАК ПланируемыеТрудозатраты
	|		ПО СтатусыОбъектовПоДням.Объект = ПланируемыеТрудозатраты.Объект
	|			И (ПланируемыеТрудозатраты.ТипТрудозатрат = ЗНАЧЕНИЕ(Перечисление.ТипыТрудозатрат.Разработка))
	|ГДЕ
	|	СтатусыОбъектовПоДням.Статус = ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Решен)
	|	И ЕСТЬNULL(ПланируемыеТрудозатраты.Трудозатраты, 0) > 2
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПланРешенныхЗадач.Объект КАК Объект,
	|	ПланРешенныхЗадач.План КАК Поинты,
	|	ВЫРАЗИТЬ(ПланРешенныхЗадач.План КАК ЧИСЛО(5, 0)) КАК ПоинтыЦелые
	|ПОМЕСТИТЬ РассчетПоинтов
	|ИЗ
	|	ПланРешенныхЗадач КАК ПланРешенныхЗадач
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	РассчетПоинтов.Объект КАК Объект,
	|	ВЫБОР
	|		КОГДА РассчетПоинтов.Поинты - РассчетПоинтов.ПоинтыЦелые > 0.5
	|			ТОГДА 1
	|		ИНАЧЕ 0
	|	КОНЕЦ + РассчетПоинтов.ПоинтыЦелые КАК ПланПоинты,
	|	Задача.Назначение КАК Назначение
	|ПОМЕСТИТЬ ПоинтыРешенныхЗадач
	|ИЗ
	|	РассчетПоинтов КАК РассчетПоинтов
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Задача КАК Задача
	|		ПО РассчетПоинтов.Объект = Задача.Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СтатусыОбъектовПоДням.ДатаКалендаря КАК ДатаКалендаря,
	|	ПоинтыРешенныхЗадач.ПланПоинты КАК Поинты,
	|	ВЫБОР
	|		КОГДА ПоинтыРешенныхЗадач.Назначение = ЗНАЧЕНИЕ(Справочник.НазначенияЗадач.Ошибка)
	|				И РАЗНОСТЬДАТ(СтатусыОбъектовПоДням.ДатаПерехода, СтатусыОбъектовПоДням.ДатаВремяУчета, ЧАС) < 24
	|			ТОГДА ПоинтыРешенныхЗадач.ПланПоинты
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК ПоинтыОшибка
	|ПОМЕСТИТЬ ДатыРешенияЗадач
	|ИЗ
	|	СтатусыОбъектовПоДням КАК СтатусыОбъектовПоДням
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ПоинтыРешенныхЗадач КАК ПоинтыРешенныхЗадач
	|		ПО СтатусыОбъектовПоДням.Объект = ПоинтыРешенныхЗадач.Объект
	|ГДЕ
	|	СтатусыОбъектовПоДням.Статус = ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Решен)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	РабочиеДни.ДатаКалендаря КАК ДатаКалендаря,
	|	ВыбранныеСтатусы.ИмяКолонки КАК ИмяКолонки,
	|	КОЛИЧЕСТВО(СтатусыОбъектовПоДням.Объект) КАК КоличествоЗадач
	|ИЗ
	|	РабочиеДни КАК РабочиеДни
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВыбранныеСтатусы КАК ВыбранныеСтатусы
	|		ПО (РабочиеДни.ДатаНаступила)
	|		ЛЕВОЕ СОЕДИНЕНИЕ СтатусыОбъектовПоДням КАК СтатусыОбъектовПоДням
	|		ПО РабочиеДни.ДатаКалендаря = СтатусыОбъектовПоДням.ДатаКалендаря
	|			И (ВыбранныеСтатусы.Статус = СтатусыОбъектовПоДням.Статус)
	|
	|СГРУППИРОВАТЬ ПО
	|	РабочиеДни.ДатаКалендаря,
	|	ВыбранныеСтатусы.ИмяКолонки
	|
	|УПОРЯДОЧИТЬ ПО
	|	ДатаКалендаря
	|ИТОГИ ПО
	|	ДатаКалендаря
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА РабочиеДни.ДатаНаступила
	|			ТОГДА РабочиеДни.ДатаКалендаря
	|		ИНАЧЕ NULL
	|	КОНЕЦ КАК ДатаКалендаря,
	|	РабочиеДни.ДатаНаступила КАК ДатаНаступила,
	|	ЕСТЬNULL(СУММА(ДатыРешенияЗадач.Поинты), 0) КАК Поинты,
	|	ЕСТЬNULL(СУММА(ДатыРешенияЗадач.ПоинтыОшибка), 0) КАК ПоинтыОшибка
	|ИЗ
	|	РабочиеДни КАК РабочиеДни
	|		ЛЕВОЕ СОЕДИНЕНИЕ ДатыРешенияЗадач КАК ДатыРешенияЗадач
	|		ПО РабочиеДни.ДатаКалендаря = ДатыРешенияЗадач.ДатаКалендаря
	|
	|СГРУППИРОВАТЬ ПО
	|	РабочиеДни.ДатаКалендаря,
	|	РабочиеДни.ДатаНаступила
	|
	|УПОРЯДОЧИТЬ ПО
	|	РабочиеДни.ДатаКалендаря
	|ИТОГИ
	|	КОЛИЧЕСТВО(ДатаКалендаря),
	|	МАКСИМУМ(Поинты),
	|	СУММА(ПоинтыОшибка)
	|ПО
	|	ОБЩИЕ";
	
 #КонецОбласти
 	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ДатаНачала", НачалоДня(Настройки.Период.ДатаНачала));
	Запрос.УстановитьПараметр("ДатаОкончания", КонецДня(Настройки.Период.ДатаОкончания));
	Запрос.УстановитьПараметр("Филиал", Настройки.Филиал);
	Запрос.УстановитьПараметр("ЧасРасчета", Настройки.ЧасРасчета);
	Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДата);
	
	Пакет = Запрос.ВыполнитьПакет();
	КоличествоПакетов = Пакет.ВГраница();
	
	ПакетПоинты = Пакет.Получить(КоличествоПакетов);
	ПакетСтатусы = Пакет.Получить(КоличествоПакетов - 1);
	
	Если НЕ ПакетСтатусы.Пустой() Тогда
		ВыборкаДней = ПакетСтатусы.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		День = 0;
		
		СерияРешен = ДиаграммаСтатусы.Серии.Добавить("Решен");
		СерияПриостановлен = ДиаграммаСтатусы.Серии.Добавить("Приостановлен");
		СерияТестирование = ДиаграммаСтатусы.Серии.Добавить("Тестирование");
		СерияCodeReview = ДиаграммаСтатусы.Серии.Добавить("Code Review");
		СерияВРаботе = ДиаграммаСтатусы.Серии.Добавить("В работе");
		СерияВРеализацию = ДиаграммаСтатусы.Серии.Добавить("В реализацию");
		
		Пока ВыборкаДней.Следующий() Цикл
			День = День + 1;
			
			НоваяСтрока = СтатусыЗадач.Добавить();
			НоваяСтрока.День = День;
			НоваяСтрока.Дата = ВыборкаДней.ДатаКалендаря;
			
			Выборка = ВыборкаДней.Выбрать();
			Пока Выборка.Следующий() Цикл
				НоваяСтрока[Выборка.ИмяКолонки] = Выборка.КоличествоЗадач;
			КонецЦикла;
			
			Точка = ДиаграммаСтатусы.УстановитьТочку(ВыборкаДней.ДатаКалендаря);
			Точка.Текст = День;
			ДиаграммаСтатусы.УстановитьЗначение(Точка, СерияРешен, НоваяСтрока.Решен);
			ДиаграммаСтатусы.УстановитьЗначение(Точка, СерияПриостановлен, НоваяСтрока.Приостановлен);
			ДиаграммаСтатусы.УстановитьЗначение(Точка, СерияТестирование, НоваяСтрока.Тестирование);
			ДиаграммаСтатусы.УстановитьЗначение(Точка, СерияCodeReview, НоваяСтрока.CodeReview);
			ДиаграммаСтатусы.УстановитьЗначение(Точка, СерияВРаботе, НоваяСтрока.ВРаботе);
			ДиаграммаСтатусы.УстановитьЗначение(Точка, СерияВРеализацию, НоваяСтрока.ВРеализацию);
		КонецЦикла;
		
		РешеноЗадач = НоваяСтрока.Решен;
	КонецЕсли; 
	
	Если НЕ ПакетПоинты.Пустой() Тогда
		День = 0;
		Идеал = Настройки.КоличествоЧеловек * Настройки.ПоинтыНаЧеловекаВДень;
		
		ВыборкаПоинты = ПакетПоинты.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		ВыборкаПоинты.Следующий();
		Выборка = ВыборкаПоинты.Выбрать();
		
		СуммаПоинтов = ВыборкаПоинты.Поинты;
		ПрошлоДней = ВыборкаПоинты.ДатаКалендаря;
		
		Если Настройки.КоличествоЧеловек = 0 ИЛИ ПрошлоДней = 0 Тогда
			ПоинтовНаЧеловека = 0;
		Иначе
			ПоинтовНаЧеловека = СуммаПоинтов / Настройки.КоличествоЧеловек / ПрошлоДней
		КонецЕсли;
		
		ПроцентОшибок = ?(СуммаПоинтов = 0, 0, ВыборкаПоинты.ПоинтыОшибка / СуммаПоинтов * 100);
		ФактВчера = 0;
		
		СерияПрогноз = ДиаграммаПоинты.Серии.Добавить("Прогноз");
		СерияИдеал = ДиаграммаПоинты.Серии.Добавить("ИдеальныйСлучай");
		СерияФакт = ДиаграммаПоинты.Серии.Добавить("Факт");
		СерияОшибки = ДиаграммаПоинтыНаЧеловека.Серии.Добавить("Ошибки");
		СерияПоинтыНаЧеловека = ДиаграммаПоинтыНаЧеловека.Серии.Добавить("Поинты на человека");
		
		Пока Выборка.Следующий() Цикл
			День = День + 1;
			
			НоваяСтрока = Поинты.Добавить();
			НоваяСтрока.День = День;
			НоваяСтрока.Прогноз = ?(ПрошлоДней = 0, 0, СуммаПоинтов * День / ПрошлоДней);
			НоваяСтрока.ИдеальныйСлучай = Идеал * День;
			
			Точка = ДиаграммаПоинты.УстановитьТочку(День);
			ДиаграммаПоинты.УстановитьЗначение(Точка, СерияПрогноз, НоваяСтрока.Прогноз);
			ДиаграммаПоинты.УстановитьЗначение(Точка, СерияИдеал, НоваяСтрока.ИдеальныйСлучай);
			
			Если Выборка.ДатаНаступила Тогда
				НоваяСтрока.Ошибки = Выборка.ПоинтыОшибка;
				НоваяСтрока.Факт = Выборка.Поинты;
				
				ФактДень = НоваяСтрока.Факт - ФактВчера;
				НоваяСтрока.ПоинтыНаЧеловека = ?(Настройки.КоличествоЧеловек = 0, 0, ФактДень / Настройки.КоличествоЧеловек);
				ФактВчера = НоваяСтрока.Факт;
				
				Если Выборка.Поинты = 0 Тогда
					ДиаграммаПоинты.УстановитьЗначение(Точка, СерияФакт, 0.1, , "0");
				Иначе
					ДиаграммаПоинты.УстановитьЗначение(Точка, СерияФакт, Выборка.Поинты);
				КонецЕсли;

				Точка = ДиаграммаПоинтыНаЧеловека.УстановитьТочку(День);
				ДиаграммаПоинтыНаЧеловека.УстановитьЗначение(Точка, СерияПоинтыНаЧеловека, НоваяСтрока.ПоинтыНаЧеловека);
				ДиаграммаПоинтыНаЧеловека.УстановитьЗначение(Точка, СерияОшибки, Выборка.ПоинтыОшибка);
			Иначе
				ДиаграммаПоинты.УстановитьЗначение(Точка, СерияФакт, -0.1);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

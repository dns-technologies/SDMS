///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Добавляет записи в регистр сведений
//
// Параметры:
//  Объект				 - СоставнойТип	 - ссылка на объект
//  Родитель			 - СоставнойТип	 - ссылка на текущего родителя
//  ПредыдущийРодитель	 - СоставнойТип	 - сслыка на предыдущего родителя
//
Процедура Добавить(Знач Объект, Знач Родитель = Неопределено, Знач ПредыдущийРодитель = Неопределено) Экспорт
	
	// Если указан предыдущий родитель, то нужно удалить записи по нему
	НаборЗаписей = СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Объект.Установить(Объект);
	
	Если ЗначениеЗаполнено(ПредыдущийРодитель) Тогда
		НаборЗаписей.Отбор.Родитель.Установить(ПредыдущийРодитель);
	Иначе
		НаборЗаписей.Отбор.Родитель.Установить(Неопределено);
	КонецЕсли;

	НаборЗаписей.Записать();
	
	// Очищаем набор записей, что бы не создавать его ещё раз
	НаборЗаписей.Очистить();
	
	// Если указан родитель, то нужно добавить запись с родителем
	Если ЗначениеЗаполнено(Родитель) Тогда
		НаборЗаписей.Отбор.Объект.Установить(Объект);	
		НаборЗаписей.Отбор.Родитель.Установить(Родитель);
		НоваяЗапись = НаборЗаписей.Добавить();
		НоваяЗапись.Объект = Объект;
		НоваяЗапись.Родитель = Родитель;
	Иначе
		НаборЗаписей.Отбор.Объект.Установить(Объект);
		НаборЗаписей.Отбор.Родитель.Установить("");
		НоваяЗапись = НаборЗаписей.Добавить();
		НоваяЗапись.Объект = Объект;
	КонецЕсли;
	
	Попытка
		НаборЗаписей.Записать();
	Исключение
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
		
КонецПроцедуры

// Возвращает признак наличия подчиненных объектов
//
// Параметры:
//  Родитель - ОпределяемыйТип.ОбъектСтруктурыПодчиненности - Ссылка на объект
// 
// Возвращаемое значение:
//   Булево - Истина, если есть подчиненные, иначе Ложь 
//
Функция ЕстьПодчиненные(Знач Родитель) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	СтруктураПодчиненности.Объект КАК Объект
	|ИЗ
	|	РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
	|ГДЕ
	|	СтруктураПодчиненности.Родитель = &Родитель";
	
	Запрос.УстановитьПараметр("Родитель", Родитель);	
	
	Возврат НЕ Запрос.Выполнить().Пустой();
	
КонецФункции

// Возвращает массив ссылок на подчиненные объекты
Функция ПолучитьПодчиненные(Знач Родитель) Экспорт
	
	Результат = Новый Массив;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	СтруктураПодчиненности.Объект КАК Объект
	|ИЗ
	|	РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
	|ГДЕ
	|	СтруктураПодчиненности.Родитель = &Родитель";
	
	Запрос.УстановитьПараметр("Родитель", Родитель);
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Результат = РезультатЗапроса.Выгрузить().ВыгрузитьКолонку("Объект");
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Функция - Получить данные структуры подчиненности
//
// Параметры:
//  Объект	 - СоставнойТип	 - ссылка на объект
// 
// Возвращаемое значение:
//   - Структура
//		*Дерево - Структура подчиненности в виде дерева
//		*Таблица - таблица значений, данные элементов структуры
//
Функция ПолучитьДанныеСтруктурыПодчиненности(Объект) Экспорт  
	
	Запрос = Новый Запрос;
	#Область ТекстЗапроса 
	// Задача в том, что бы для одного объекта определить все родительские узлы и все подчиненные родительских на всю глубину иерархии.
	// Для построения запроса используется транзитивное замыкание. Таким способом для каждого элемента получается список всех его родителей. 
	// При этом всех родителей я получаю только для проектов и внутренних задач, так как только у них могут быть вложенные иерархии.
	// У задачи родитель - только заявка, у заявка - либо проект, либо внутреннее задание. Таким образом замыкание выполняется достаточно быстро. 
	// 1. Сначала отбираю нужные объекты из регистра СтруктураПодченности 
	// 2. Потом транзитивным замыканием получаю всех родителей для каждого элемента
	// 3. Следущим шагом для текущего объекта отбираю всех родителей и всех подчиненных этих родителей
	// 4. Строю корректную иерархию. Оставляю только те записи, где разница уровня родителя и уровня объекта = 1.
	//    Есть нюанс, иногда в регистре нет верхней иерархии (то есть объект - самый верхний документ, а родитель пустой)
	//    Иногда объекта вообще в регистре нет. Поэтому в таблицу ДанныеИерархия добавляю такое насильно и убираю повторы.
	// 5. Так как построенная иерархия это только проекты и внутренние задачи, то добавляю еще задачи и заявки  
	// 6. Выбираю доп данные для заявок.
	// 7. Скармливаю результат запроса СКД, что бы получилось кастомная иерархия. Выгружаю деревом.
		
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СтруктураПодчиненности.Объект КАК Ссылка,
	|	СтруктураПодчиненности.Родитель КАК ОбъектОснование
	|ПОМЕСТИТЬ ПодчиненныеДокументы
	|ИЗ
	|	РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
	|ГДЕ
	|	СтруктураПодчиненности.Объект ССЫЛКА Документ.ВнутреннееЗадание
	|	И НЕ СтруктураПодчиненности.Родитель = НЕОПРЕДЕЛЕНО
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	СтруктураПодчиненности.Объект,
	|	СтруктураПодчиненности.Родитель
	|ИЗ
	|	РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
	|ГДЕ
	|	СтруктураПодчиненности.Объект ССЫЛКА Справочник.Проекты
	|	И НЕ СтруктураПодчиненности.Родитель = НЕОПРЕДЕЛЕНО
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	СтруктураПодчиненности.Объект,
	|	СтруктураПодчиненности.Родитель
	|ИЗ
	|	РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
	|ГДЕ
	|	СтруктураПодчиненности.Объект = &Заявка
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	СтруктураПодчиненности.Объект,
	|	СтруктураПодчиненности.Родитель
	|ИЗ
	|	РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
	|ГДЕ
	|	СтруктураПодчиненности.Объект = &Задача
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПодчиненныеДокументы.ОбъектОснование КАК НачалоДуги,
	|	ПодчиненныеДокументы.Ссылка КАК КонецДуги
	|ПОМЕСТИТЬ ЗамыканияДлины1
	|ИЗ
	|	ПодчиненныеДокументы КАК ПодчиненныеДокументы
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	ПодчиненныеДокументы.Ссылка,
	|	ПодчиненныеДокументы.Ссылка
	|ИЗ
	|	ПодчиненныеДокументы КАК ПодчиненныеДокументы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ПерваяДуга.НачалоДуги КАК НачалоДуги,
	|	ВтораяДуга.КонецДуги КАК КонецДуги
	|ПОМЕСТИТЬ ЗамыканияДлины2
	|ИЗ
	|	ЗамыканияДлины1 КАК ПерваяДуга
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ЗамыканияДлины1 КАК ВтораяДуга
	|		ПО ПерваяДуга.КонецДуги = ВтораяДуга.НачалоДуги
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ ЗамыканияДлины1
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ПерваяДуга.НачалоДуги КАК НачалоДуги,
	|	ВтораяДуга.КонецДуги КАК КонецДуги
	|ПОМЕСТИТЬ ЗамыканияДлины4
	|ИЗ
	|	ЗамыканияДлины2 КАК ПерваяДуга
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ЗамыканияДлины2 КАК ВтораяДуга
	|		ПО ПерваяДуга.КонецДуги = ВтораяДуга.НачалоДуги
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ ЗамыканияДлины2
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ПерваяДуга.НачалоДуги КАК НачалоДуги,
	|	ВтораяДуга.КонецДуги КАК КонецДуги
	|ПОМЕСТИТЬ ЗамыканияДлины8
	|ИЗ
	|	ЗамыканияДлины4 КАК ПерваяДуга
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ЗамыканияДлины4 КАК ВтораяДуга
	|		ПО ПерваяДуга.КонецДуги = ВтораяДуга.НачалоДуги
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ ЗамыканияДлины4
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ПерваяДуга.НачалоДуги КАК НачалоДуги,
	|	ВтораяДуга.КонецДуги КАК КонецДуги
	|ПОМЕСТИТЬ ЗамыканияДлины16
	|ИЗ
	|	ЗамыканияДлины8 КАК ПерваяДуга
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ЗамыканияДлины8 КАК ВтораяДуга
	|		ПО ПерваяДуга.КонецДуги = ВтораяДуга.НачалоДуги
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ ЗамыканияДлины8
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗамыканияДлины16.НачалоДуги КАК Предок,
	|	ЗамыканияДлины16.КонецДуги КАК Потомок
	|ПОМЕСТИТЬ Данные
	|ИЗ
	|	ЗамыканияДлины16 КАК ЗамыканияДлины16
	|ГДЕ
	|	ЗамыканияДлины16.НачалоДуги <> ЗамыканияДлины16.КонецДуги
	|	И ЗамыканияДлины16.НачалоДуги <> НЕОПРЕДЕЛЕНО
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ ЗамыканияДлины16
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Данные.Предок КАК Предок
	|ПОМЕСТИТЬ Предки
	|ИЗ
	|	Данные КАК Данные
	|ГДЕ
	|	Данные.Потомок = &ссылка
	|	И НЕ Данные.Предок = НЕОПРЕДЕЛЕНО
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Данные.Потомок КАК Потомок
	|ПОМЕСТИТЬ Потомки
	|ИЗ
	|	Данные КАК Данные
	|ГДЕ
	|	Данные.Предок = &ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Данные.Потомок КАК Объект
	|ПОМЕСТИТЬ ОтобранныеОбъекты
	|ИЗ
	|	Данные КАК Данные
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Предки КАК Предки
	|		ПО (Предки.Предок = Данные.Предок)
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	Предки.Предок
	|ИЗ
	|	Предки КАК Предки
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	Потомки.Потомок
	|ИЗ
	|	Потомки КАК Потомки
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Данные.Предок КАК Родитель,
	|	Данные.Потомок КАК Объект
	|ПОМЕСТИТЬ ОтобранныеДанные
	|ИЗ
	|	Данные КАК Данные
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ОтобранныеОбъекты КАК ОтобранныеОбъекты
	|		ПО Данные.Предок = ОтобранныеОбъекты.Объект
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	Данные.Предок,
	|	Данные.Потомок
	|ИЗ
	|	Данные КАК Данные
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ОтобранныеОбъекты КАК ОтобранныеОбъекты
	|		ПО Данные.Потомок = ОтобранныеОбъекты.Объект
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КОЛИЧЕСТВО(ОтобранныеДанные.Родитель) КАК Уровень,
	|	ОтобранныеДанные.Объект КАК Объект
	|ПОМЕСТИТЬ Уровни
	|ИЗ
	|	ОтобранныеДанные КАК ОтобранныеДанные
	|
	|СГРУППИРОВАТЬ ПО
	|	ОтобранныеДанные.Объект
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ОтобранныеДанные.Родитель КАК Родитель,
	|	ОтобранныеДанные.Объект КАК Объект
	|ПОМЕСТИТЬ ДанныеИерархия
	|ИЗ
	|	ОтобранныеДанные КАК ОтобранныеДанные
	|		ЛЕВОЕ СОЕДИНЕНИЕ Уровни КАК УровниОбъекта
	|		ПО (УровниОбъекта.Объект = ОтобранныеДанные.Объект)
	|		ЛЕВОЕ СОЕДИНЕНИЕ Уровни КАК УровниРодителя
	|		ПО (УровниРодителя.Объект = ОтобранныеДанные.Родитель)
	|ГДЕ
	|	ЕСТЬNULL(УровниОбъекта.Уровень, 0) - ЕСТЬNULL(УровниРодителя.Уровень, 0) = 1
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	СтруктураПодчиненности.Родитель,
	|	СтруктураПодчиненности.Объект
	|ИЗ
	|	РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
	|ГДЕ
	|	СтруктураПодчиненности.Объект = &ссылка
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	НЕОПРЕДЕЛЕНО,
	|	ОтобранныеДанные.Родитель
	|ИЗ
	|	ОтобранныеДанные КАК ОтобранныеДанные
	|		ЛЕВОЕ СОЕДИНЕНИЕ Уровни КАК УровниОбъекта
	|		ПО (УровниОбъекта.Объект = ОтобранныеДанные.Родитель)
	|ГДЕ
	|	УровниОбъекта.Уровень ЕСТЬ NULL
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	НЕОПРЕДЕЛЕНО,
	|	&Ссылка
	|ГДЕ
	|	НЕ 1 В
	|				(ВЫБРАТЬ
	|					1
	|				ИЗ
	|					ОтобранныеДанные
	|				ГДЕ
	|					ОтобранныеДанные.Объект = &Ссылка)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДанныеИерархия.Родитель КАК Родитель,
	|	ДанныеИерархия.Объект КАК Объект
	|ПОМЕСТИТЬ ДанныеИерархияЗаявки
	|ИЗ
	|	ДанныеИерархия КАК ДанныеИерархия
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	ДанныеИерархия.Объект,
	|	СтруктураПодчиненности.Объект
	|ИЗ
	|	ДанныеИерархия КАК ДанныеИерархия
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
	|		ПО (СтруктураПодчиненности.Родитель = ДанныеИерархия.Объект)
	|			И (СтруктураПодчиненности.Объект ССЫЛКА Документ.ЗаявкаНаРазработку)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ ДанныеИерархия
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДанныеИерархияЗаявки.Родитель КАК Родитель,
	|	ДанныеИерархияЗаявки.Объект КАК Объект
	|ПОМЕСТИТЬ ДанныеИерархияЗаявкиЗадачи
	|ИЗ
	|	ДанныеИерархияЗаявки КАК ДанныеИерархияЗаявки
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	ДанныеИерархияЗаявки.Объект,
	|	СтруктураПодчиненности.Объект
	|ИЗ
	|	ДанныеИерархияЗаявки КАК ДанныеИерархияЗаявки
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
	|		ПО (СтруктураПодчиненности.Родитель = ДанныеИерархияЗаявки.Объект)
	|			И (СтруктураПодчиненности.Объект ССЫЛКА Документ.Задача)
	|			И (СтруктураПодчиненности.Родитель ССЫЛКА Документ.ЗаявкаНаРазработку)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ ДанныеИерархияЗаявки
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ДанныеИерархияЗаявкиЗадачи.Объект КАК Объект
	|ПОМЕСТИТЬ ВыбранныеОбъекты
	|ИЗ
	|	ДанныеИерархияЗаявкиЗадачи КАК ДанныеИерархияЗаявкиЗадачи
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ДокументЗадача.Ссылка КАК Объект,
	|	ДокументЗадача.Представление КАК ПредставлениеОбъекта,
	|	ДокументЗадача.Статус КАК Статус,
	|	ДокументЗадача.СистемаУчета КАК Система,
	|	ДокументЗадача.Направление КАК Направление,
	|	ДокументЗадача.ПометкаУдаления КАК ПометкаУдаления,
	|	""Документ.Задача"" КАК ПолноеИмяМетаданных
	|ПОМЕСТИТЬ ДополненныеЗадачи
	|ИЗ
	|	Документ.Задача КАК ДокументЗадача
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВыбранныеОбъекты КАК ВыбранныеОбъекты
	|		ПО (ВыбранныеОбъекты.Объект = ДокументЗадача.Ссылка)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ДокументЗаявкаНаРазработку.Ссылка КАК Объект,
	|	ДокументЗаявкаНаРазработку.Представление КАК ПредставлениеОбъекта,
	|	ВЫБОР
	|		КОГДА ДокументЗаявкаНаРазработку.ФинальныйСтатус <> ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.ПустаяСсылка)
	|			ТОГДА ДокументЗаявкаНаРазработку.ФинальныйСтатус
	|		ИНАЧЕ ЕСТЬNULL(МинимальныеСтатусыЗаявок.Статус, ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Новый))
	|	КОНЕЦ КАК Статус,
	|	ЗНАЧЕНИЕ(Справочник.СистемыУчета.ПустаяСсылка) КАК Система,
	|	ДокументЗаявкаНаРазработку.Направление КАК Направление,
	|	ДокументЗаявкаНаРазработку.ПометкаУдаления КАК ПометкаУдаления,
	|	""Документ.ЗаявкаНаРазработку"" КАК ПолноеИмяМетаданных,
	|	ДокументЗаявкаНаРазработку.Черновик КАК Черновик
	|ПОМЕСТИТЬ ДополненныеЗаявки
	|ИЗ
	|	Документ.ЗаявкаНаРазработку КАК ДокументЗаявкаНаРазработку
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВыбранныеОбъекты КАК ВыбранныеОбъекты
	|		ПО (ВыбранныеОбъекты.Объект = ДокументЗаявкаНаРазработку.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.МинимальныеСтатусыЗаявок КАК МинимальныеСтатусыЗаявок
	|		ПО ДокументЗаявкаНаРазработку.Ссылка = МинимальныеСтатусыЗаявок.Заявка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	Проекты.Ссылка КАК Объект,
	|	Проекты.Представление КАК ПредставлениеОбъекта,
	|	Проекты.Статус КАК Статус,
	|	ЗНАЧЕНИЕ(Справочник.СистемыУчета.ПустаяСсылка) КАК Система,
	|	Проекты.Направление КАК Направление,
	|	Проекты.ПометкаУдаления КАК ПометкаУдаления,
	|	""Справочник.Проекты"" КАК ПолноеИмяМетаданных
	|ПОМЕСТИТЬ ДополненныеПроекты
	|ИЗ
	|	Справочник.Проекты КАК Проекты
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВыбранныеОбъекты КАК ВыбранныеОбъекты
	|		ПО (ВыбранныеОбъекты.Объект = Проекты.Ссылка)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВнутреннееЗадание.Ссылка КАК Объект,
	|	ВнутреннееЗадание.Представление КАК ПредставлениеОбъекта,
	|	ВнутреннееЗадание.Статус КАК Статус,
	|	ВнутреннееЗадание.СистемаУчета КАК Система,
	|	ВнутреннееЗадание.Направление КАК Направление,
	|	ВнутреннееЗадание.ПометкаУдаления КАК ПометкаУдаления,
	|	""Документ.ВнутреннееЗадание"" КАК ПолноеИмяМетаданных
	|ПОМЕСТИТЬ ДополненныеВнутренниеЗадания
	|ИЗ
	|	Документ.ВнутреннееЗадание КАК ВнутреннееЗадание
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВыбранныеОбъекты КАК ВыбранныеОбъекты
	|		ПО (ВыбранныеОбъекты.Объект = ВнутреннееЗадание.Ссылка)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДополненныеЗаявки.Объект КАК Объект,
	|	ДополненныеЗаявки.ПредставлениеОбъекта КАК ПредставлениеОбъекта,
	|	ДополненныеЗаявки.Статус КАК Статус,
	|	ДополненныеЗаявки.Направление КАК Направление,
	|	ДополненныеЗаявки.Система КАК Система,
	|	ДополненныеЗаявки.ПометкаУдаления КАК ПометкаУдаления,
	|	ДополненныеЗаявки.ПолноеИмяМетаданных КАК ПолноеИмяМетаданных,
	|	ДополненныеЗаявки.Черновик КАК Черновик
	|ПОМЕСТИТЬ ВсеОбъекты
	|ИЗ
	|	ДополненныеЗаявки КАК ДополненныеЗаявки
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ДополненныеЗадачи.Объект,
	|	ДополненныеЗадачи.ПредставлениеОбъекта,
	|	ДополненныеЗадачи.Статус,
	|	ДополненныеЗадачи.Направление,
	|	ДополненныеЗадачи.Система,
	|	ДополненныеЗадачи.ПометкаУдаления,
	|	ДополненныеЗадачи.ПолноеИмяМетаданных,
	|	ЛОЖЬ
	|ИЗ
	|	ДополненныеЗадачи КАК ДополненныеЗадачи
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ДополненныеВнутренниеЗадания.Объект,
	|	ДополненныеВнутренниеЗадания.ПредставлениеОбъекта,
	|	ДополненныеВнутренниеЗадания.Статус,
	|	ДополненныеВнутренниеЗадания.Направление,
	|	ДополненныеВнутренниеЗадания.Система,
	|	ДополненныеВнутренниеЗадания.ПометкаУдаления,
	|	ДополненныеВнутренниеЗадания.ПолноеИмяМетаданных,
	|	ЛОЖЬ
	|ИЗ
	|	ДополненныеВнутренниеЗадания КАК ДополненныеВнутренниеЗадания
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ДополненныеПроекты.Объект,
	|	ДополненныеПроекты.ПредставлениеОбъекта,
	|	ДополненныеПроекты.Статус,
	|	ДополненныеПроекты.Направление,
	|	ДополненныеПроекты.Система,
	|	ДополненныеПроекты.ПометкаУдаления,
	|	ДополненныеПроекты.ПолноеИмяМетаданных,
	|	ЛОЖЬ
	|ИЗ
	|	ДополненныеПроекты КАК ДополненныеПроекты
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВсеОбъекты.Объект КАК Ссылка,
	|	ВсеОбъекты.ПредставлениеОбъекта КАК Представление,
	|	ВсеОбъекты.Статус КАК Статус,
	|	ВсеОбъекты.Направление КАК НаправлениеРазработки,
	|	ВсеОбъекты.Система КАК СистемаУчета,
	|	ВЫБОР
	|		КОГДА ВсеОбъекты.Черновик
	|			ТОГДА ""Черновик""
	|		ИНАЧЕ СтатусыОбъектов.Наименование
	|	КОНЕЦ КАК СтатусНаименование,
	|	ВЫБОР
	|		КОГДА ВсеОбъекты.Черновик
	|			ТОГДА &ИндексКартинкиЧерновик
	|		ИНАЧЕ СтатусыОбъектов.ИндексКартинки
	|	КОНЕЦ КАК ИндексКартинки,
	|	ВсеОбъекты.ПометкаУдаления КАК ПометкаУдаления,
	|	ВсеОбъекты.ПолноеИмяМетаданных КАК ПолноеИмяМетаданных,
	|	ВЫБОР
	|		КОГДА ВсеОбъекты.Объект = &Ссылка
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК ТекущийОбъект
	|ИЗ
	|	ВсеОбъекты КАК ВсеОбъекты
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтатусыОбъектов КАК СтатусыОбъектов
	|		ПО ВсеОбъекты.Статус = СтатусыОбъектов.Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДанныеИерархияЗаявкиЗадачи.Родитель КАК Родитель,
	|	ДанныеИерархияЗаявкиЗадачи.Объект КАК Ссылка
	|ИЗ
	|	ДанныеИерархияЗаявкиЗадачи КАК ДанныеИерархияЗаявкиЗадачи";  
	#КонецОбласти
	
	Запрос.УстановитьПараметр("Ссылка", Объект);
	Запрос.УстановитьПараметр("ИндексКартинкиЧерновик", Справочники.СтатусыОбъектов.ИндексКартинкиЧерновик());

	Если типЗнч(Объект) = тип("ДокументСсылка.Задача") Тогда
		Запрос.УстановитьПараметр("Задача", Объект);    
		Запрос.УстановитьПараметр("Заявка", ОбщегоНазначенияВызовСервера.ЗначениеРеквизитаОбъекта(Объект, "ОбъектОснование"));    
	ИначеЕсли типЗнч(Объект) = тип("ДокументСсылка.ЗаявкаНаРазработку") Тогда
		Запрос.УстановитьПараметр("Задача", Неопределено);    
		Запрос.УстановитьПараметр("Заявка", Объект);    
	Иначе
		Запрос.УстановитьПараметр("Задача", Неопределено);    
		Запрос.УстановитьПараметр("Заявка", Неопределено); 
	КонецЕсли;
	
	Результат = Запрос.ВыполнитьПакет();
	Данные = Результат[Результат.ВГраница() - 1].Выгрузить();
	Иерархия = Результат[Результат.ВГраница()].Выбрать();	
	
	СтандартнаяОбработка = Ложь;
	ВнешниеНаборыДанных = Новый Структура;
	ВнешниеНаборыДанных.Вставить("Данные", Данные);	
	ВнешниеНаборыДанных.Вставить("Иерархия", Иерархия);
	
	СхемаКомпоновкиДанных = ПолучитьМакет("ФормированиеСтруктурыПодчиненности");
	
	КомпоновщикНастроек = Новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаКомпоновкиДанных));
	КомпоновщикНастроек.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);

	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;	
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, КомпоновщикНастроек.ПолучитьНастройки(),,, 
		Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));	
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;	
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, ВнешниеНаборыДанных);	
		
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;	
	ДеревоЗначений = Новый ДеревоЗначений;
	ПроцессорВывода.УстановитьОбъект(ДеревоЗначений);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);   	
	
	Возврат Новый Структура("Дерево, Таблица", ДеревоЗначений, Данные);  
	
КонецФункции

// Возвращает массив потомков объекта на всю глубину иерархии
//
// Параметры:
//  Объект - СправочникСсылка.Проекты, ДокументСсылка.ВнутреннееЗадание, ДокументСсылка.ЗаявкаНаРазработку - ссылка на объект
// 
// Возвращаемое значение:
//  Массив - массив подчиненных объектов 
//			(СправочникСсылка.Проекты, ДокументСсылка.ВнутреннееЗадание, ДокументСсылка.ЗаявкаНаРазработку, ДокументСсылка.Задача)
//
Функция ПолучитьПодчиненныеОбъектыСИерархией(Объект) Экспорт
	
	МассивПодчиненных = Новый Массив;
	
	Запрос = Новый Запрос;
	 
	// Задача в том, чтобы для одного объекта определить все подчиненные на всю глубину иерархии.
	// Для построения запроса используется транзитивное замыкание. Таким способом для каждого элемента получается список всех его родителей. 
	// При этом определяются все родители только для проектов и внутренних заданий, так как только у них могут быть вложенные иерархии.
	// У задачи родитель - только заявка, у заявки - либо проект, либо внутреннее задание. Таким образом замыкание выполняется достаточно быстро. 
	// Для заявок выполняется более простой запрос, т.к. у заявок подчиненными могут быть только задачи, а у задач подчиненных объектов нет. 
	// Для остальных типов объектов (Проекты и Внутренние задания) используется следующий алгоритм:	
	// 1. Сначала отбираем нужные объекты из регистра СтруктураПодченности 
	// 2. Потом транзитивным замыканием получаем всех родителей для каждого элемента.
	// 3. Из полученных данных отбираем только потомки переданного объекта (это будут Проекты и Внутренние задания). 
	// 4. Определяем все заявки, которые могут быть потомками объектов, полученных на шаге 3.
	// 5. Определяем все задачи, которые могут быть потомками заявок, полученных на шаге 4, объединяем с полученными ранее объектами (на шагах 3 и 4).
	
	Если ТипЗнч(Объект) = Тип("ДокументСсылка.ЗаявкаНаРазработку") Тогда
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	СтруктураПодчиненности.Объект
		|ИЗ
		|	РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
		|ГДЕ
		|	СтруктураПодчиненности.Родитель = &Ссылка";
	
	Иначе		
		Запрос.Текст =
		"ВЫБРАТЬ
		|	СтруктураПодчиненности.Объект КАК Ссылка,
		|	СтруктураПодчиненности.Родитель КАК ОбъектОснование
		|ПОМЕСТИТЬ ПодчиненныеДокументы
		|ИЗ
		|	РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
		|ГДЕ
		|	СтруктураПодчиненности.Объект ССЫЛКА Документ.ВнутреннееЗадание
		|	И НЕ СтруктураПодчиненности.Родитель = НЕОПРЕДЕЛЕНО
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	СтруктураПодчиненности.Объект,
		|	СтруктураПодчиненности.Родитель
		|ИЗ
		|	РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
		|ГДЕ
		|	СтруктураПодчиненности.Объект ССЫЛКА Справочник.Проекты
		|	И НЕ СтруктураПодчиненности.Родитель = НЕОПРЕДЕЛЕНО
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ПодчиненныеДокументы.ОбъектОснование КАК НачалоДуги,
		|	ПодчиненныеДокументы.Ссылка КАК КонецДуги
		|ПОМЕСТИТЬ ЗамыканияДлины1
		|ИЗ
		|	ПодчиненныеДокументы КАК ПодчиненныеДокументы
		|
		|ОБЪЕДИНИТЬ
		|
		|ВЫБРАТЬ
		|	ПодчиненныеДокументы.Ссылка,
		|	ПодчиненныеДокументы.Ссылка
		|ИЗ
		|	ПодчиненныеДокументы КАК ПодчиненныеДокументы
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ПерваяДуга.НачалоДуги КАК НачалоДуги,
		|	ВтораяДуга.КонецДуги КАК КонецДуги
		|ПОМЕСТИТЬ ЗамыканияДлины2
		|ИЗ
		|	ЗамыканияДлины1 КАК ПерваяДуга
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ЗамыканияДлины1 КАК ВтораяДуга
		|		ПО ПерваяДуга.КонецДуги = ВтораяДуга.НачалоДуги
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|УНИЧТОЖИТЬ ЗамыканияДлины1
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ПерваяДуга.НачалоДуги КАК НачалоДуги,
		|	ВтораяДуга.КонецДуги КАК КонецДуги
		|ПОМЕСТИТЬ ЗамыканияДлины4
		|ИЗ
		|	ЗамыканияДлины2 КАК ПерваяДуга
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ЗамыканияДлины2 КАК ВтораяДуга
		|		ПО ПерваяДуга.КонецДуги = ВтораяДуга.НачалоДуги
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|УНИЧТОЖИТЬ ЗамыканияДлины2
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ПерваяДуга.НачалоДуги КАК НачалоДуги,
		|	ВтораяДуга.КонецДуги КАК КонецДуги
		|ПОМЕСТИТЬ ЗамыканияДлины8
		|ИЗ
		|	ЗамыканияДлины4 КАК ПерваяДуга
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ЗамыканияДлины4 КАК ВтораяДуга
		|		ПО ПерваяДуга.КонецДуги = ВтораяДуга.НачалоДуги
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|УНИЧТОЖИТЬ ЗамыканияДлины4
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ПерваяДуга.НачалоДуги КАК НачалоДуги,
		|	ВтораяДуга.КонецДуги КАК КонецДуги
		|ПОМЕСТИТЬ ЗамыканияДлины16
		|ИЗ
		|	ЗамыканияДлины8 КАК ПерваяДуга
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ЗамыканияДлины8 КАК ВтораяДуга
		|		ПО ПерваяДуга.КонецДуги = ВтораяДуга.НачалоДуги
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|УНИЧТОЖИТЬ ЗамыканияДлины8
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ЗамыканияДлины16.НачалоДуги КАК Предок,
		|	ЗамыканияДлины16.КонецДуги КАК Потомок
		|ПОМЕСТИТЬ Данные
		|ИЗ
		|	ЗамыканияДлины16 КАК ЗамыканияДлины16
		|ГДЕ
		|	ЗамыканияДлины16.НачалоДуги <> ЗамыканияДлины16.КонецДуги
		|	И ЗамыканияДлины16.НачалоДуги <> НЕОПРЕДЕЛЕНО
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|УНИЧТОЖИТЬ ЗамыканияДлины16
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Данные.Потомок КАК Объект
		|ПОМЕСТИТЬ ПотомкиПроектыИВнутренниеЗадания
		|ИЗ
		|	Данные КАК Данные
		|ГДЕ
		|	Данные.Предок = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	СтруктураПодчиненности.Объект КАК Объект
		|ПОМЕСТИТЬ ПотомкиЗаявкиНаРазработку
		|ИЗ
		|	ПотомкиПроектыИВнутренниеЗадания КАК Потомки
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаявкаНаРазработку КАК ЗаявкаНаРазработку
		|			ПО СтруктураПодчиненности.Объект = ЗаявкаНаРазработку.Ссылка
		|		ПО (СтруктураПодчиненности.Родитель = Потомки.Объект)
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	СтруктураПодчиненности.Объект
		|ИЗ
		|	РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаявкаНаРазработку КАК ЗаявкаНаРазработку
		|		ПО СтруктураПодчиненности.Объект = ЗаявкаНаРазработку.Ссылка
		|ГДЕ
		|	СтруктураПодчиненности.Родитель = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ПотомкиПроектыИВнутренниеЗадания.Объект КАК Объект
		|ИЗ
		|	ПотомкиПроектыИВнутренниеЗадания КАК ПотомкиПроектыИВнутренниеЗадания
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ПотомкиЗаявкиНаРазработку.Объект
		|ИЗ
		|	ПотомкиЗаявкиНаРазработку КАК ПотомкиЗаявкиНаРазработку
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	СтруктураПодчиненности.Объект
		|ИЗ
		|	ПотомкиЗаявкиНаРазработку КАК Потомки
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
		|		ПО (СтруктураПодчиненности.Родитель = Потомки.Объект)
		|			И (СтруктураПодчиненности.Объект ССЫЛКА Документ.Задача)
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	СтруктураПодчиненности.Объект
		|ИЗ
		|	РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
		|ГДЕ
		|	СтруктураПодчиненности.Родитель = &Ссылка
		|	И СтруктураПодчиненности.Объект ССЫЛКА Документ.Задача";
		
	КонецЕсли;
		
	Запрос.УстановитьПараметр("Ссылка", Объект);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл 
		МассивПодчиненных.Добавить(Выборка.Объект);
	КонецЦикла;
	
	Возврат МассивПодчиненных;
	
КонецФункции

#КонецОбласти

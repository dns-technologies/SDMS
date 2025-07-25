
#Область ОбработчикиСобытийФормы

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Импорт(Команда)
	
	Файл = Новый Файл(ФайлИмпорта);
	Если Не Файл.Существует() Тогда 
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Выберите файл для импорта.'");
		Сообщение.Поле = "ФайлИмпорта";
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	ДвоичныеДанные = Новый ДвоичныеДанные(ФайлИмпорта);
	АдресХранилища = ПоместитьВоВременноеХранилище(ДвоичныеДанные, ЭтотОбъект.УникальныйИдентификатор);
	ВыполнитьИмпортНаСервере(ФайлИмпорта, АдресХранилища);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Процедура ВыполнитьИмпортНаСервере(ИмяФайла, АдресХранилища)
	
	ОценкаПроизводительности.ЗагрузитьФайлОценкиПроизводительности(ИмяФайла, АдресХранилища);
	
КонецПроцедуры

#КонецОбласти

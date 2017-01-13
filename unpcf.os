#Использовать logos
#Использовать gitsync

Перем Лог;
Перем Sync, Runner;
Перем СтрокаПодключения;
Перем ПутьИстории, КаталогИсходниковCF, КаталогИсходниковEPF;

procedure Инициализация()
 
    Лог = Логирование.ПолучитьЛог("vega.unpcf.cf");
    Лог.УстановитьУровень(УровниЛога.Отладка);
    
    ВыводПоУмолчанию = Новый ВыводЛогаВКонсоль();
    Лог.ДобавитьСпособВывода(ВыводПоУмолчанию);
	
	SystemInfo = new SystemInfo;
	Deploy_Server1C 		= SystemInfo.GetEnvironmentVariable("Deploy_Server1C");
	Deploy_Catalog 			= SystemInfo.GetEnvironmentVariable("Deploy_Catalog");
	Deploy_SourceCatalog 	= SystemInfo.GetEnvironmentVariable("Deploy_SourceCatalog");
	
	Лог.Отладка("Deploy_Server1C="+Deploy_Server1C);
	Лог.Отладка("Deploy_Catalog="+Deploy_Catalog);
	Лог.Отладка("Deploy_SourceCatalog="+Deploy_SourceCatalog);
	
	Если Deploy_Server1C = "" Тогда
		Лог.Ошибка("Сервер разработки не указан! заполните Deploy_Server1C");
		ЗавершитьРаботу(1);
	КонецЕсли;

	Если Deploy_Catalog = "" Тогда
		Лог.Ошибка("Каталог скриптов не указан! заполните Deploy_Catalog");
		ЗавершитьРаботу(1);
	КонецЕсли;

	Если Deploy_SourceCatalog = "" Тогда
		Лог.Ошибка("Каталог исходников не указан! заполните Deploy_SourceCatalog");
		ЗавершитьРаботу(1);
	КонецЕсли;

	ФайлМенеджерСинхронизации = Новый Файл(ОбъединитьПути(Deploy_Catalog, "МенеджерСинхронизации.os"));
	Если ФайлМенеджерСинхронизации.Существует() Тогда
		ПодключитьСценарий(ФайлМенеджерСинхронизации.ПолноеИмя, "ObjSync");
		Sync = Новый ObjSync();
	Иначе
		Лог.Ошибка("Не найден скрипт ""МенеджерСинхронизации.os"" ");
		ЗавершитьРаботу(1);
	КонецЕсли;
	
	ФайлRunner = Новый Файл(ОбъединитьПути(Deploy_Catalog, "Runner.os"));
	Если ФайлRunner.Существует() Тогда
		ПодключитьСценарий(ФайлRunner.ПолноеИмя, "ObjRunner");
		Runner = Новый ObjRunner();
		Runner.ТихийРежим = Истина;
	Иначе
		Runner = Неопределено;
		Лог.Ошибка("Не найден скрипт ""Runner.os"". Разборка EPF не подерживается!");
		ЗавершитьРаботу(1);
	КонецЕсли;

	ТекКаталог = ТекущийКаталог();
	Лог.Отладка("ТекКаталог="+ТекКаталог);

	РВ = Новый РегулярноеВыражение("\\");
	НачалоПоискаБазы = Ложь;
	ИмяБазы = "";
	МаркерНеобходимостиРазбораОбработок = "history";
	НеобходимостьРазбораОбработок = Ложь;

	ПутьИстории = "";
	
	Для Каждого Параметр Из РВ.Разделить(ТекКаталог) Цикл
		Если Параметр = Deploy_Server1C Тогда
			НачалоПоискаБазы = Истина;
		ИначеЕсли НачалоПоискаБазы = Истина Тогда
			ИмяБазы = Параметр;
			НачалоПоискаБазы = Ложь;
		КонецЕсли;
		
		Если НеобходимостьРазбораОбработок = Ложь Тогда
			ПутьИстории = ОбъединитьПути(ПутьИстории, Параметр + ?(ПутьИстории="", "\", ""));
		КонецЕсли;

		Если МаркерНеобходимостиРазбораОбработок = НРег(Параметр) Тогда
			НеобходимостьРазбораОбработок = Истина;
		КонецЕсли;
		
		Лог.Отладка(Параметр);
	КонецЦикла;

	Если ИмяБазы = "" Тогда
		Лог.Ошибка("ИмяБазы не определено!");
		ЗавершитьРаботу(1);
	КонецЕсли;

	Если НеобходимостьРазбораОбработок = Ложь Тогда
		Лог.Ошибка("Не обнаружен каталог разбора обработок!");
		ЗавершитьРаботу(1);
	КонецЕсли;

	КаталогИсходниковCF = ОбъединитьПути(Deploy_SourceCatalog, ИмяБазы, "CF");
	КаталогИсходниковEPF = ОбъединитьПути(Deploy_SourceCatalog, ИмяБазы, "EPF");
	
	Лог.Отладка("ИмяБазы =" + ИмяБазы);  
	Лог.Отладка("ПутьИстории =" + ПутьИстории); 
	Лог.Отладка("КаталогИсходников CF =" + КаталогИсходниковCF);  
	Лог.Отладка("КаталогИсходников EPF =" + КаталогИсходниковEPF);  

	СтрокаПодключения = "/S" + Deploy_Server1C + "\" + ИмяБазы;
	Лог.Отладка("СтрокаПодключения="+СтрокаПодключения);

	ПроверитьИСоздатьКаталог(КаталогИсходниковCF);
	
	Если Sync.ПроверитьНаличиеРепозитарияГит(КаталогИсходниковCF) = Ложь Тогда
		Sync.ИнициализироватьРепозитарий(КаталогИсходниковCF);
	КонецЕсли;
	
	Если ЕстьРаспаковщикEPF() Тогда
		ПроверитьИСоздатьКаталог(КаталогИсходниковEPF);
		Если Sync.ПроверитьНаличиеРепозитарияГит(КаталогИсходниковEPF) = Ложь Тогда
			Sync.ИнициализироватьРепозитарий(КаталогИсходниковEPF);
		КонецЕсли;
	КонецЕсли;
	
	ОбработатьКаталогИстории();
	
endprocedure

function ЕстьРаспаковщикEPF() Экспорт
    Возврат НЕ (Runner = Неопределено);
endfunction

procedure ПроверитьИСоздатьКаталог(Знач Каталог)
	ФайлКаталога = Новый Файл(Каталог);
	Если НЕ ФайлКаталога.Существует() Тогда
		СоздатьКаталог(Каталог);
	КонецЕсли; 	
endprocedure

function Форматировать(Знач Уровень, Знач Сообщение) Экспорт
    Возврат СтрШаблон("%1: %2 - %3", ТекущаяДата(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);
endfunction

procedure ОбработатьКаталогИстории()

	КаталогCF  = ОбъединитьПути(ПутьИстории, "CF");
	ПроверитьИСоздатьКаталог(ОбъединитьПути(КаталогCF, "commited"));

	//cf
	СписокФайлов = НайтиФайлы(КаталогCF, "*.cf", Ложь);
	// предобработка (необходимо выполнить в порядке возрастания даты, иначе список будет сортирован по наименованию)
	ТЗ = Новый ТаблицаЗначений();
	ТЗ.Колонки.Добавить("Имя");
	ТЗ.Колонки.Добавить("ПолноеИмя");
	ТЗ.Колонки.Добавить("Расширение");
	ТЗ.Колонки.Добавить("ДатаИзменения");

	Для Каждого Файл Из СписокФайлов Цикл
		Если Файл.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;
		НС = ТЗ.Добавить();
		НС.Имя = Файл.Имя;
		НС.ПолноеИмя = Файл.ПолноеИмя;
		НС.Расширение = Файл.Расширение;
		НС.ДатаИзменения = Файл.GetModificationTime();
	КонецЦикла;
	ТЗ.Сортировать("ДатаИзменения");
	
	Для Каждого Файл Из ТЗ Цикл
		Ошибка = ОбработатьФайлCF(Файл);
		Если Ошибка Тогда Прервать; КонецЕсли;
	КонецЦикла;
	
	//epf
	Если ЕстьРаспаковщикEPF() Тогда
		КаталогEPF = ОбъединитьПути(ПутьИстории, "EPF");
		СписокФайлов = НайтиФайлы(КаталогEPF, ПолучитьМаскуВсеФайлы(), Ложь);
		Для Каждого Файл Из СписокФайлов Цикл
			Если Файл.ЭтоКаталог() Тогда
				ОбработатьКаталогEPF(Файл.ПолноеИмя);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
endprocedure

procedure ОбработатьКаталогEPF(Знач КаталогОбработки)

	СписокФайлов = НайтиФайлы(КаталогОбработки, "*.e?f", Ложь);
	ПроверитьИСоздатьКаталог(ОбъединитьПути(КаталогОбработки, "commited"));
	
	// предобработка (необходимо выполнить в порядке возрастания даты, иначе список будет сортирован по наименованию)
	ТЗ = Новый ТаблицаЗначений();
	ТЗ.Колонки.Добавить("Имя");
	ТЗ.Колонки.Добавить("ПолноеИмя");
	ТЗ.Колонки.Добавить("Расширение");
	ТЗ.Колонки.Добавить("ДатаИзменения");

	Для Каждого Файл Из СписокФайлов Цикл
		Если Файл.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;
		НС = ТЗ.Добавить();
		НС.Имя = Файл.Имя;
		НС.ПолноеИмя = Файл.ПолноеИмя;
		НС.Расширение = Файл.Расширение;
		НС.ДатаИзменения = Файл.GetModificationTime();
	КонецЦикла;
	ТЗ.Сортировать("ДатаИзменения");
	
	Для Каждого Файл Из ТЗ Цикл
		Ошибка = ОбработатьФайлEPF(Файл, КаталогОбработки);
		Если Ошибка Тогда Прервать; КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

function ОбработатьФайлEPF(Знач Файл, Знач КаталогОбработки)

	КВФ = КаталогВременныхФайлов();
	
	НовоеИмяФайла = ОбъединитьПути(КВФ, Новый Файл(КаталогОбработки).Имя)+ Файл.Расширение;
	КопироватьФайл(Файл.ПолноеИмя, НовоеИмяФайла); 
	
	Ошибка = Ложь;
	Попытка
		Runner.Декомпилировать(НовоеИмяФайла, КаталогИсходниковEPF,, СтрокаПодключения);
		ВыполнитьКоммит(КаталогИсходниковEPF, Файл.Имя, Файл.ДатаИзменения);
	Исключение
		Ошибка = Истина;
	КонецПопытки;
	
	Если Ошибка = Ложь Тогда
		ПереместитьФайл(Файл.ПолноеИмя, ОбъединитьПути(КаталогОбработки, "commited", Файл.Имя));
		Лог.Отладка("Обработан файл epf : " + Файл.Имя);
	КонецЕсли;
	
	УдалитьФайлы(НовоеИмяФайла);
	
	Возврат Ошибка;

КонецФункции

function ОбработатьФайлCF(Знач Файл)

	Ошибка = Ложь;
	Попытка
		Sync.РазобратьФайлКонфигурации(Файл.ПолноеИмя, КаталогИсходниковCF, РежимВыгрузкиФайлов.Авто);
		ВыполнитьКоммит(КаталогИсходниковCF, Файл.Имя, Файл.ДатаИзменения);
	Исключение
		Ошибка = Истина;
	КонецПопытки;
	
	Если Ошибка = Ложь Тогда
		ПереместитьФайл(Файл.ПолноеИмя, ОбъединитьПути(ПутьИстории, "CF", "commited", Файл.Имя));
		Лог.Отладка("Обработан файл cf : " + Файл.Имя);
	КонецЕсли;
	
	Возврат Ошибка;

endfunction

procedure ВыполнитьКоммит(Знач Каталог, Знач Коммент, Знач ДатаИзменения);
	
	Автор = "";
	Ошибка = Ложь;
	Попытка
		Sync.ВыполнитьКоммитГит(Каталог, Коммент, Автор, ДатаИзменения);
	Исключение
		Лог.Ошибка("Ошибка коммита " + Коммент);
		Ошибка = Истина;
	КонецПопытки;

endprocedure


Инициализация();




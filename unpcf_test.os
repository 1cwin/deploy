#Использовать logos
#Использовать gitsync

Перем Лог;
Перем Sync;
Перем ПутьИстории;
Перем КаталогИсходников;

Процедура Инициализация()
 
    Лог = Логирование.ПолучитьЛог("vega.save.cf");
    Лог.УстановитьУровень(УровниЛога.Отладка);
    
    ВыводПоУмолчанию = Новый ВыводЛогаВКонсоль();
    Лог.ДобавитьСпособВывода(ВыводПоУмолчанию);
	
	SystemInfo = new SystemInfo;
	Deploy_Server1C 		= SystemInfo.GetEnvironmentVariable("Deploy_Server1C");
	Deploy_SourceCatalog 	= SystemInfo.GetEnvironmentVariable("Deploy_SourceCatalog");
	Deploy_Catalog 			= SystemInfo.GetEnvironmentVariable("Deploy_Catalog");
	
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
	
	Sync.УстановитьРежимУдаленияВременныхФайлов(Истина);
	Лог.Отладка("" + Sync.УдалятьВременныеФайлы);  
	
КонецПроцедуры

Инициализация();




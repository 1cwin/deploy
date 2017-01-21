#Использовать logos
#Использовать gitsync

Перем Лог;
Перем Sync, Runner;
Перем СтрокаПодключения;
Перем ПутьИстории, КаталогИсходников, соотвСозданныхКаталогов;

procedure Инициализация()
 
    Лог = Логирование.ПолучитьЛог("vega.dev.getcurcf");
    Лог.УстановитьУровень(УровниЛога.Отладка);
    
    ВыводПоУмолчанию = Новый ВыводЛогаВКонсоль();
    Лог.ДобавитьСпособВывода(ВыводПоУмолчанию);
	
	SystemInfo = new SystemInfo;
	dev_Server1C 		= SystemInfo.GetEnvironmentVariable("dev_Server1C");
	dev_Catalog 		= SystemInfo.GetEnvironmentVariable("dev_Catalog");
	dev_SourceCatalog 	= SystemInfo.GetEnvironmentVariable("dev_SourceCatalog");
	
	Лог.Отладка("dev_Server1C=" 	+ dev_Server1C);
	Лог.Отладка("dev_Catalog=" 		+ dev_Catalog);
	Лог.Отладка("dev_SourceCatalog="+ dev_SourceCatalog);
	
	Если dev_Server1C = "" Тогда
		Лог.Ошибка("Сервер разработки не указан! заполните dev_Server1C");
		ЗавершитьРаботу(1);
	КонецЕсли;

	Если dev_Catalog = "" Тогда
		Лог.Ошибка("Каталог скриптов не указан! заполните dev_Catalog");
		ЗавершитьРаботу(1);
	КонецЕсли;

	Если dev_SourceCatalog = "" Тогда
		Лог.Ошибка("Каталог исходников не указан! заполните dev_SourceCatalog");
		ЗавершитьРаботу(1);
	КонецЕсли;
	
	ФайлRunner = Новый Файл(ОбъединитьПути(dev_Catalog, "lib", "Runner.os"));
	Если ФайлRunner.Существует() Тогда
		ПодключитьСценарий(ФайлRunner.ПолноеИмя, "ObjRunner");
		Runner = Новый ObjRunner();
	Иначе
		Runner = Неопределено;
		Лог.Ошибка("Не найден скрипт ""Runner.os"". Разборка обработок и отчетов не подерживается!");
		ЗавершитьРаботу(1);
	КонецЕсли;

	ТекКаталог = ТекущийКаталог();
	Лог.Отладка("ТекКаталог="+ТекКаталог);

	РВ = Новый РегулярноеВыражение("\\");
	НачалоПоискаБазы = Ложь;
	ИмяБазы = "";
	МаркерНеобходимостиРазбораОбработок = "history";
	НеобходимостьРазбора = Ложь;

	ПутьИстории = "";
	Для Каждого Параметр Из РВ.Разделить(ТекКаталог) Цикл
		Если Параметр = dev_Server1C Тогда
			НачалоПоискаБазы = Истина;
		ИначеЕсли НачалоПоискаБазы = Истина Тогда
			ИмяБазы = Параметр;
			НачалоПоискаБазы = Ложь;
		КонецЕсли;
		Если НеобходимостьРазбора = Ложь Тогда
			ПутьИстории = ОбъединитьПути(ПутьИстории, Параметр + ?(ПутьИстории="", "\", ""));
		КонецЕсли;
		Если МаркерНеобходимостиРазбораОбработок = НРег(Параметр) Тогда
			НеобходимостьРазбора = Истина;
		КонецЕсли;
		Лог.Отладка(Параметр);
	КонецЦикла;

	Если ИмяБазы = "" Тогда
		Лог.Ошибка("ИмяБазы не определено!");
		ЗавершитьРаботу(1);
	КонецЕсли;

	Если НеобходимостьРазбора = Ложь Тогда
		Лог.Ошибка("Не обнаружен каталог ""history""!");
		ЗавершитьРаботу(1);
	КонецЕсли;
	
	Лог.Отладка("ИмяБазы =" + ИмяБазы);  
	Лог.Отладка("ПутьИстории =" + ПутьИстории); 

	СтрокаПодключения = "/S" + dev_Server1C + "\" + ИмяБазы;
	Лог.Отладка("СтрокаПодключения="+СтрокаПодключения);
	
	соотвСозданныхКаталогов = Новый Соответствие;
	ВыгрузитьCFТекущий();
	
endprocedure

procedure ПроверитьИСоздатьКаталог(Знач Каталог)
	Если соотвСозданныхКаталогов.Получить(Каталог) = Неопределено Тогда
		ФайлКаталога = Новый Файл(Каталог);
		Если НЕ ФайлКаталога.Существует() Тогда
			СоздатьКаталог(Каталог);
			Лог.Отладка("Создан каталог = "+Каталог);
		КонецЕсли; 	
		соотвСозданныхКаталогов.Вставить(Каталог, Истина);
	КонецЕсли;
endprocedure

procedure ВыгрузитьCFТекущий()

	КаталогCF  = ОбъединитьПути(ПутьИстории, "CF");
	ФайлКонфигурации = ОбъединитьПути(КаталогCF, ДатаPOSIX(ТекущаяДата()) + ".cf");
    
	Конфигуратор = Новый УправлениеКонфигуратором();
    Конфигуратор.УстановитьКонтекст(СтрокаПодключения, "", "");
    ПараметрыЗапуска = Конфигуратор.ПолучитьПараметрыЗапуска();
    ПараметрыЗапуска.Добавить("/Visible");
    ПараметрыЗапуска.Добавить("/DumpCfg """ + ФайлКонфигурации + """");
    Конфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);	
	
endprocedure

function ДатаPOSIX(Знач Дата)

	Возврат "" + Год(Дата) + "" + ФорматДвузначноеЧисло(Месяц(Дата)) + "" + ФорматДвузначноеЧисло(День(Дата)) + "_"
			+ ФорматДвузначноеЧисло(Час(Дата)) + "" + ФорматДвузначноеЧисло(Минута(Дата)) + "" + ФорматДвузначноеЧисло(Секунда(Дата));

КонецФункции

function ФорматДвузначноеЧисло(ЗначениеЧисло)
	С = Строка(ЗначениеЧисло);
	Если СтрДлина(С) < 2 Тогда
		С = "0" + С;
	КонецЕсли;

	Возврат С;
КонецФункции


Инициализация();




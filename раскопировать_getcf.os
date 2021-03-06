#Использовать logos

Перем Лог;
Перем ПутьИстории;
Перем КаталогИсходников;

procedure Инициализация()
 
    Лог = Логирование.ПолучитьЛог("vega.dev.copyunpcf");
    Лог.УстановитьУровень(УровниЛога.Отладка);
    
    ВыводПоУмолчанию = Новый ВыводЛогаВКонсоль();
    Лог.ДобавитьСпособВывода(ВыводПоУмолчанию);
	
	SystemInfo = new SystemInfo;
	dev_EPF 	= SystemInfo.GetEnvironmentVariable("dev_EPF");
	dev_Catalog = SystemInfo.GetEnvironmentVariable("dev_Catalog");
	
	Лог.Отладка("dev_EPF="+dev_EPF);
	Лог.Отладка("dev_Catalog="+dev_Catalog);
	
	Если dev_EPF = "" Тогда
		Лог.Ошибка("Сервер разработки не указан! заполните dev_EPF");
		ЗавершитьРаботу(1);
	КонецЕсли;

	ТекКаталог = ТекущийКаталог();
	Лог.Отладка("ТекКаталог="+ТекКаталог);

	Если dev_Catalog = "" Тогда
		dev_Catalog = ТекКаталог;
	КонецЕсли;

	ФайлКаталога = Новый Файл(dev_EPF);
	Если ФайлКаталога.Существует() = Ложь Тогда
		Лог.Ошибка("Каталог копирования не обнаружен");
		ЗавершитьРаботу(1);
	КонецЕсли; 	

	_ИмяСкриптаДляКопирования = ИмяСкрипта();
	Поз = СтрНайти(_ИмяСкриптаДляКопирования, "_");
	ИмяСкриптаДляКопирования = Сред(_ИмяСкриптаДляКопирования, Поз+1) + ".os";
	ПолноеИмяСкриптаДляКопирования = ОбъединитьПути(dev_Catalog, ИмяСкриптаДляКопирования);

	Лог.Отладка("ИмяСкриптаДляКопирования=" + ИмяСкриптаДляКопирования);

	ФайлСкрипта = Новый Файл(ПолноеИмяСкриптаДляКопирования);
	Если ФайлСкрипта.Существует() = Ложь Тогда
		Лог.Ошибка("Файл cкрипта не обнаружен");
		ЗавершитьРаботу(1);
	КонецЕсли; 	
	
	СписокФайлов = НайтиФайлы(dev_EPF, ПолучитьМаскуВсеФайлы(), Истина);
	Для Каждого Файл Из СписокФайлов Цикл
		Если Файл.ЭтоКаталог() Тогда
			ПолноеИмя = Файл.ПолноеИмя;
			Если Нрег(Прав(ПолноеИмя,7)) = "history" Тогда
				Лог.Отладка(ПолноеИмя);
				КопироватьФайл(ПолноеИмяСкриптаДляКопирования, ОбъединитьПути(ПолноеИмя, ИмяСкриптаДляКопирования));
			КонецЕсли;
		Иначе
			Продолжить;
		КонецЕсли;
	КонецЦикла	
	
endProcedure

function ИмяСкрипта()
    ФайлИсточника = Новый Файл(ТекущийСценарий().Источник);
    Возврат ФайлИсточника.ИмяБезРасширения;
endfunction


Инициализация();




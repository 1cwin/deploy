#Использовать logos

Перем Лог;

procedure Инициализация()
 
    Лог = Логирование.ПолучитьЛог("vega.dev.copyunpcf");
    Лог.УстановитьУровень(УровниЛога.Отладка);
    
    ВыводПоУмолчанию = Новый ВыводЛогаВКонсоль();
    Лог.ДобавитьСпособВывода(ВыводПоУмолчанию);
	
	oShell = new COMObject("WScript.Shell");
	FavoritesPath = oShell.SpecialFolders("Desktop");
	oShortCut = oShell.CreateShortcut(ОбъединитьПути(FavoritesPath, "sqlRetail_getcf.lnk"));
	oShortCut.TargetPath = "d:\rbdev\sqlRetail\history\getcf.os";
	oShortCut.WorkingDirectory = "d:\rbdev\sqlRetail\history";
	oShortCut.IconLocation = "%SystemRoot%\system32\shell32.dll, 68";
	oShortCut.Save();

endprocedure 

Инициализация();




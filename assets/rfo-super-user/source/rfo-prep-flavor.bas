
%----------------------------------------------
% RFO-BASIC! Compiler Super User
%----------------------------------------------

GW_COLOR$="black"
GW_SILENT_LOAD=1
INCLUDE "GW.bas"
INCLUDE "utils_str.bas"
INCLUDE "utils_file.bas"

%-- Version Nb & Code -------------------------
ver$  = VERSION$()  % version name
IF IS_APK()
 verx$ = VERSIONX$() % version code
ELSE
 verx$ = "N/A"
ENDIF
verx$ = " (" + verx$ + ")"
%----------------------------------------------

%---- Welcome ---------------------------------
this$ = "BASIC! SuperUser v" + ver$ + verx$
? "Welcome to " + this$
GOSUB DefFns
%----------------------------------------------

LF$ = CHR$(10)
CR$ = CHR$(13)
DQ$ = CHR$(34)
rfopath$ = "../../rfo-basic/"
comppath$ = "../../rfo-compiler/"
LIST.CREATE s, files

%----------------------------------------------
% Make the 2 theme custos (light & dark)
%----------------------------------------------
light=GW_NEW_THEME_CUSTO("color='a'")
dark=GW_NEW_THEME_CUSTO("color='b'")

%----------------------------------------------
% Make the 2 title bars shared by all screens
%----------------------------------------------
dummy = GW_NEW_PAGE()
% First one :   [        TITLE (Exit) ]
tibar1$ = GW_ADD_BAR_TITLE$(this$)
GW_USE_THEME_CUSTO_ONCE("icon=power notext")
tibar1$ += GW_ADD_BAR_RBUTTON$(">EXIT")
% Second one :  [ (Back) TITLE (Exit) ]
GW_USE_THEME_CUSTO_ONCE("icon=back notext")
tibar2$ = GW_ADD_BAR_LBUTTON$(">BACK")
tibar2$ += GW_ADD_BAR_TITLE$(this$)
GW_USE_THEME_CUSTO_ONCE("icon=power notext")
tibar2$ += GW_ADD_BAR_RBUTTON$(">EXIT")

%----------------------------------------------
% Make the icon class shared by all screens
%----------------------------------------------
ico_css$ ="<style>.ico{width:50px;height:"
ico_css$+="50px;padding:2px;filter:invert("
IF drk_thm THEN ico_css$ += "10"
ico_css$+="0%)}</style>"
FN.DEF AddIcoBtn$(icon$, btn_txt$, btn_axn$)
 GW_USE_THEME_CUSTO_ONCE("class='ico'")
 e$ = GW_ADD_IMAGE$(icon$)
 e$ += GW_SHELF_NEWCELL$()
 IF btn_axn$ = "NEW" | IS_IN("Download", btn_txt$)
  s$  = "style='background:#888;"
  s$ += "color:white;text-shadow:none'"
  GW_USE_THEME_CUSTO_ONCE(s$)
 ENDIF
 e$ += GW_ADD_BUTTON$(btn_txt$, btn_axn$)
 GW_USE_THEME_CUSTO_ONCE("style='height:10px'")
 e$ += GW_SHELF_NEWROW$()
 FN.RTN e$
FN.END

%----------------------------------------------
% File Picker: create page
%----------------------------------------------
GW_USE_THEME_CUSTO(light)
INCLUDE "GW_PICK_FILE.bas"
FILE.ROOT GW_FOLDER$ % override start folder
GW_FOLDER$ += "/"
BUNDLE.PUT 1, "GW_FOLDER", GW_FOLDER$

%----------------------------------------------
% Flavors menu: create page
%----------------------------------------------
GW_USE_THEME_CUSTO(light)
pg_flav = GW_NEW_PAGE()

ARRAY.LOAD ok$[], "OK"
GW_USE_THEME_CUSTO_ONCE("inline")
dlgm = GW_ADD_DIALOG_MESSAGE(pg_flav, "BASIC! Super User", "Flavor was correctly imported: it is ready for use in the Compiler after you activate the Super User option in the option panel (gear icon at the top left).", ok$[])

ARRAY.LOAD yesno$[], "Yes>DELFLAV", "NO!"
GW_USE_THEME_CUSTO_ONCE("inline")
dlgd = GW_ADD_DIALOG_MESSAGE(pg_flav, "", "Remove this flavor ?\n(we'll keep the zip file)", yesno$[])

ARRAY.LOAD flav$[], "RFO-BASIC>DLRFO", "OliBasic>DLOLI", "hbasic>DLHB", "Cancel"
GW_USE_THEME_CUSTO_ONCE("inline")
dlg_dl = GW_ADD_DIALOG_MESSAGE(pg_flav, "Download a BASIC! flavor", "Open the web page of one of these BASIC! flavors to download a zip of its source code (Android Project):", flav$[])
GW_CUSTO_DLGBTN(pg_flav, dlg_dl, "Cancel", "style='background:#888;color:white;text-shadow:none'")

GW_USE_THEME_CUSTO_ONCE("icon=eye notext")
GW_ADD_TITLEBAR(pg_flav, GW_ADD_BAR_LBUTTON$(">THEME") + tibar1$)

GW_INJECT_HTML(pg_flav, ico_css$)
GW_USE_THEME_CUSTO_ONCE("style='width:54'")
GW_SHELF_OPEN(pg_flav)
e$ = AddIcoBtn$("flavor.png", "Download a BASIC! flavor", GW_SHOW_DIALOG$(dlg_dl))
GW_INJECT_HTML(pg_flav, e$)
GW_SHELF_NEWROW(pg_flav)
e$ = AddIcoBtn$("zip.png", "Import flavor from zip", "NEW")
GW_INJECT_HTML(pg_flav, e$)
GW_SHELF_CLOSE(pg_flav)

GW_INJECT_HTML(pg_flav, "<div>")
pgbar = GW_ADD_PROGRESSBAR(pg_flav, "")
GW_INJECT_HTML(pg_flav, "</div>")

ARRAY.LOAD lv_flav$[], " |Use an option from the buttons above| "
lv_flav = GW_ADD_LISTVIEW(pg_flav, lv_flav$[])
lv$ = GW_ID$(lv_flav)

%----------------------------------------------
% Flavor config: create page
%----------------------------------------------
GW_USE_THEME_CUSTO(light)
pg_cfg = GW_NEW_PAGE()

tb_cfg = GW_ADD_TITLEBAR(pg_cfg, tibar2$)

GW_ADD_TEXTBOX(pg_cfg, "This page allows you to change the default settings of the flavor that will be used to compile your APKs. But please note that these settings may be overwritten when using the Compiler advanced or super advanced options.")

GW_SHELF_OPEN(pg_cfg)
GW_INJECT_HTML(pg_cfg, "SDK min: " + GW_ADD_INPUTMINI$("0"))
mi_sdkmin = GW_LAST_ID()
GW_SHELF_NEWCELL(pg_cfg)
GW_USE_THEME_CUSTO_ONCE("color=b")
GW_INJECT_HTML(pg_cfg, "SDK target: " + GW_ADD_INPUTMINI$("0"))
mi_sdktgt = GW_LAST_ID()
GW_SHELF_CLOSE(pg_cfg)

ARRAY.LOAD inst$[], "auto", "preferExternal"
sb_inst = GW_ADD_SELECTBOX(pg_cfg, "Installation location:", inst$[])

ARRAY.LOAD concol$[], "Black Text On White Screen", "White Text on Black Screen", "White Text on Blue Screen"
ARRAY.LOAD concol2$[], "BW", "WB", "WBL"
sb_concol = GW_ADD_SELECTBOX(pg_cfg, "Console color scheme:", concol$[])
ARRAY.LOAD consiz$[], "Small", "Medium", "Large"
sb_consiz = GW_ADD_SELECTBOX(pg_cfg, "Console font size:", consiz$[])
ARRAY.LOAD contyp$[], "Monospace", "Sans Serif", "Serif"
ARRAY.LOAD contyp2$[], "MS", "SS", "S"
sb_contyp = GW_ADD_SELECTBOX(pg_cfg, "Console font typeface:", contyp$[])
ARRAY.LOAD orient$[], "Variable By Sensors" ~
 "Fixed Landscape", "Fixed Reverse Landscape" ~
 "Fixed Portrait", "Fixed Reverse Portrait"
ARRAY.LOAD orient2$[], "0", "1", "2", "3", "4"
sb_conori = GW_ADD_SELECTBOX(pg_cfg, "Console orientation:", orient$[])

GW_SHELF_OPEN(pg_cfg)
GW_ADD_TEXT(pg_cfg, "Display console menu:")
GW_SHELF_NEWCELL(pg_cfg)
sw_conmnu = GW_ADD_FLIPSWITCH(pg_cfg, "", "false", "true")

GW_SHELF_NEWROW(pg_cfg)
GW_ADD_TEXT(pg_cfg, "Use lined console:")
GW_SHELF_NEWCELL(pg_cfg)
sw_conlin = GW_ADD_FLIPSWITCH(pg_cfg, "", "false", "true")

GW_SHELF_NEWROW(pg_cfg)
GW_ADD_TEXT(pg_cfg, "Show splash screen:")
GW_SHELF_NEWCELL(pg_cfg)
sw_splash = GW_ADD_FLIPSWITCH(pg_cfg, "", "false", "true")
GW_SHELF_CLOSE(pg_cfg)

col_splash = GW_ADD_COLORPICKER(pg_cfg, "Splash screen color:", "000000")
html$ = "Splash screen timer: " + GW_ADD_INPUTMINI$("0")
GW_INJECT_HTML(pg_cfg, html$)
mi_splash = GW_LAST_ID()

css$ = "style='color:white;text-shadow:none;"
GW_USE_THEME_CUSTO_ONCE(css$ + "background:green'")
GW_ADD_BUTTON(pg_cfg, "SAVE SETTINGS", "SAVE")

GW_USE_THEME_CUSTO_ONCE(css$ + "background:red'")
GW_ADD_BUTTON(pg_cfg, "CANCEL CONFIGURATION", "BACK")


%----------------------------------------------
% Apply the theme to all created pages
%----------------------------------------------
IF drk_thm THEN GOSUB ChangeTheme

Flav_Menu:
%----------------------------------------------
% List the flavors (.desc) & populate the page
%----------------------------------------------
FILE.DIR "", f$[], "/"
ARRAY.LENGTH nf, f$[]
desc=0
FOR i=1 TO nf
 IF RIGHT$(f$[i], 5) = ".desc" THEN desc++ ELSE f$[i]=""
NEXT
IF desc>0
 DIM flav$[desc]
 DIM lv_flav$[desc]
 desc=0
 FOR i=1 TO nf
  IF f$[i]<>""
   f$=LEFT$(f$[i],-5)
   flav$[++desc]=f$
   lnk$=">NFO:"+f$
   ico$="@@"+f$+"/res/drawable-hdpi/icon.png"
   lv_flav$[desc] ="Setup|"+f$+lnk$+ico$+"|Delete"
  ENDIF
 NEXT
ELSE
 ARRAY.LOAD lv_flav$[], "Use an option from the buttons above"
ENDIF

%----------------------------------------------
% Flavors menu: display page, handle user input
%----------------------------------------------
GW_RENDER(pg_flav)
GW_AMODIFY(lv_flav, "content", lv_flav$[])
GW_HIDE(pgbar)
IF showdlgm
 showdlgm = 0
 GW_SHOW_DIALOG(dlgm)
ENDIF

DO
 r$ = GW_WAIT_ACTION$()
 IF r$ = "EXIT" | r$ = "BACK"
  IF IS_APK() THEN EXIT ELSE END
 ELSEIF r$ = "THEME"
  drk_thm = 1 - drk_thm
  GOSUB ChangeTheme
  GOTO Flav_Menu
 ELSEIF r$ = "DLRFO"
  BROWSE "https://github.com/RFO-BASIC/Basic/releases"
  r$ = ""
 ELSEIF r$ = "DLOLI"
  BROWSE "https://gitlab.com/OliBasic/Main"
  r$ = ""
 ELSEIF r$ = "DLHB"
  BROWSE "http://laughton.com/basic/programs/tools/hbasic/source/"
  r$ = ""
 ELSEIF IS_IN("NFO:",r$)
  f$=MID$(r$, 5)
  GRABFILE nfo$, f$+".desc"
  e$ ="     "+f$+"\n    ("
  e$+=TRIM$(nfo$)+")\nswipe "
  e$+="left/right for options"
  POPUP e$
  r$=""
 ELSEIF IS_IN(lv$,r$) % swipe listview option (setup/delete)
  r$ = MID$(r$, LEN(lv$)+2) % remove listview id + '>'
  IF IS_IN("Setup", r$)
   r$ = REPLACE$(r$, "Setup#", "CFG:")
  ELSEIF IS_IN("Delete", r$)
   row = VAL(MID$(r$, LEN("Delete")+2))
   GW_SHOW_DIALOG(dlgd) % confirmation box
   r$=""
  ENDIF
 ELSEIF r$="DELFLAV"
  GW_HIDE_LISTVIEW_ROW(lv_flav, row)
  f$ = flav$[row]
  FILE.DELETE fd, f$+".desc"
  ?"- Delete "+f$+".desc - OK"
  FILE.DELETE fd, f$+".lst"
  ?"  Delete "+f$+".lst - OK"
  DelRecursivePath(f$, files, 1)
  ?"  Delete whole '"+f$+"' folder - OK"
  % Keep arrays up-to-date
  DIM lv_flav$[--desc]
  FOR i=row TO desc
   flav$[i] = flav$[i+1]
   lnk$=">NFO:"+flav$[i]
   ico$="@@"+flav$[i]+"/res/drawable-hdpi/icon.png"
   lv_flav$[i] ="Setup|"+flav$[i]+lnk$+ico$+"|Delete"
  NEXT
  r$=""
 ENDIF
UNTIL LEN(r$)

IF r$ = "NEW"
 zip$ = GW_PICK_FILE$("*.zip")
 IF zip$ = "" THEN GOTO Flav_Menu
ELSEIF IS_IN("CFG:", r$) = 1 % user single-tapped on a project -> open it
 proj$ = flav$[VAL(MID$(r$, 5))]
 GOTO Flav_Config
ELSE % unknown command
 GOTO Flav_Menu
ENDIF

%----------------------------------------------
% Import flavor from zip
%----------------------------------------------

GW_RENDER(pg_flav) % pgbar is showing
GW_AMODIFY(lv_flav, "content", lv_flav$[])
proj$ = LEFT$(FileName$(zip$), -4)
CLS % clear console
? "Welcome to " + this$
? "Importing flavor " + proj$

% Flavor already prepared?
% -------------------------

FILE.EXISTS fe, proj$
IF fe
 e$ = "!Replacing existing flavor " + proj$
 GOSUB UpdatePgbar
 PAUSE 1000
 c1 = CLOCK()
 DelRecursivePath(proj$, files, 1)
 ? "Existing " + proj$ + " cleaned in " + INT$(CLOCK()-c1) + " ms."
ENDIF

% Import flavor from zip
% -----------------------

c0 = CLOCK()
ZIP.COUNT zip$, nzip % number of entries in the zip

ZIP.OPEN r, zid, zip$
IF zid < 0
 e$="!Failed opening " + DQ$ + zip$ + DQ$
 GOSUB UpdatePgbar
 GOTO FinImport
ENDIF

? "Opening " + DQ$ + REPLACE$(zip$, "../", "") + DQ$ + " (" + INT$(nzip) + " zip entries)"
ZIP.DIR zip$, all$[], "/" % list content of the zip
ARRAY.LENGTH nfiles, all$[]
main$ = all$[1] : main$ = LEFT$(main$, IS_IN("/", main$)) % root folder

% Get package name
% -----------------

FOR i=1 TO nfiles
 IF IS_IN("AndroidManifest.xml", all$[i])
  mnf$ = all$[i]
  all$[i] += "/Thumbs.db" % trick so that it's ignored afterwards
  F_N.BREAK
 ENDIF
NEXT
IF mnf$=""
 e$ = "!Not an Android project! Import failed"
 GOSUB UpdatePgbar
 GOTO FinImport
ENDIF
ZIP.READ zid, buf$, mnf$
j = IS_IN("<?xml version=", LOWER$(buf$))
i = IS_IN("package=\"", buf$)
IF !i | !j
 e$ = "!Not an Android project! Import failed"
 GOSUB UpdatePgbar
 GOTO FinImport
ENDIF
i += LEN("package=\"")
j = IS_IN(DQ$, buf$, i)
pkg$ = MID$(buf$, i, j-i)
jav$ = REPLACE$(pkg$, ".", "/")
NotifLib$ = pkg$ + ".notify.NotifyClassic"
? "Found package " + DQ$ + pkg$ + DQ$

% Treat Manifest
% ---------------

c1 = CLOCK()
buf$ = REPLACE$(buf$, CR$, "")
% Remove all comments
i = IS_IN("<!--", buf$)
WHILE i
 k = IS_IN("-->", buf$, i) + LEN("-->")
 buf$ = LEFT$(buf$, i-1) + MID$(buf$, k)
 i = IS_IN("<!--", buf$)
REPEAT
% Reset permissions
i = IS_IN("<uses-permission", buf$)     : i = IS_IN(LF$, buf$, i - LEN(buf$))
k = IS_IN("<uses-permission", buf$, -1) : k = IS_IN(LF$, buf$, k)
buf$ = LEFT$(buf$, i) + MID$(buf$, k+1)
% Unregister .bas file extension
i = IS_IN("android:pathPattern=\".*//.bas", buf$)
IF !i THEN i = IS_IN("android:pathPattern=\".*\\\\.bas", buf$)
IF i
 i = IS_IN("<intent-filter", buf$, i - LEN(buf$)) : i = IS_IN(LF$, buf$, i - LEN(buf$))
 k = IS_IN("</intent-filter>", buf$, i) : k = IS_IN(LF$, buf$, k)
 buf$ = LEFT$(buf$, i) + MID$(buf$, k+1)
ENDIF
% Unregister launcher shortcut
i = IS_IN("android:name=\"LauncherShortcuts", buf$)
IF !i THEN i = IS_IN("android:name=\"" + pkg$ + ".LauncherShortcuts", buf$)
i = IS_IN("<activity", buf$, i - LEN(buf$)) : i = IS_IN(LF$, buf$, i - LEN(buf$))
k = IS_IN("</activity>", buf$, i) : k = IS_IN(LF$, buf$, k)
buf$ = LEFT$(buf$, i) + MID$(buf$, k+1)
i = IS_IN("android:name=\"CreateShortcuts", buf$)
i = IS_IN("<activity-alias", buf$, i - LEN(buf$)) : i = IS_IN(LF$, buf$, i - LEN(buf$))
k = IS_IN("</activity-alias>", buf$, i) : k = IS_IN(LF$, buf$, k)
buf$ = LEFT$(buf$, i) + MID$(buf$, k+1)
% Add large heap memory setting (disabled by default)
IF !IS_IN("android:largeHeap", buf$)
 i = IS_IN("<application", buf$) : i = IS_IN(LF$, buf$, i)
 buf$ = LEFT$(buf$, i) + "        android:largeHeap=\"false\"" + MID$(buf$, i)
ENDIF
% Remove blank lines
i = IS_IN(LF$+LF$, buf$)
WHILE i
 buf$ = REPLACE$(buf$, LF$+LF$, LF$)
 i = IS_IN(LF$+LF$, buf$)
REPEAT
PutFile(buf$, proj$ + "/AndroidManifest.xml")
? "Manifest treated in " + INT$(CLOCK()-c1) + " ms."

% Treat all otter files
% ----------------------

nvalid = 0
FOR i=1 TO nfiles
 f$ = all$[i]
 % Test file against various schemes
 IF RIGHT$(f$, 1) = "/" THEN all$[i] = "" % skip folders
 IF LEFT$(FileName$(f$), 1) = "." THEN all$[i] = "" % skip hidden files
 IF RIGHT$(f$, 6) = ".prefs" THEN all$[i] = "" % skip Eclipse files
 IF RIGHT$(f$, 5) = ".html" THEN all$[i] = "" % skip Javadoc
 IF RIGHT$(f$, 11) = ".properties" THEN all$[i] = "" % skip Ant files
 IF FileName$(f$) = "README.txt"  THEN all$[i] = "" % skip Readme
 IF FileName$(f$) = "Thumbs.db"  THEN all$[i] = "" % skip crap
 IF IS_IN(main$ + "assets", f$) THEN all$[i] = "" % skip Assets folder
 IF IS_IN(main$ + "bin", f$) THEN all$[i] = "" % skip Bin folder
 IF IS_IN(main$ + "gen", f$) THEN all$[i] = "" % skip Gen folder
 IF all$[i] <> "" THEN nvalid++
NEXT

ntreated = 0
FOR i=1 TO nfiles
 f$ = all$[i]
 IF f$ = "" THEN F_N.CONTINUE
 c1 = CLOCK()
 ntreated++

 % Get file content
 GW_SET_PROGRESSBAR(pgbar, INT(100*ntreated/nvalid))
 e$ = "Importing " + MID$(f$, LEN(main$)+1)
 GOSUB UpdatePgbar
 ZIP.READ zid, buf$, f$
 file$ = proj$ + MID$(f$, LEN(main$))

 % Special case: SPLIT java files into .head/.body
 IF RIGHT$(file$, 5) = ".java" & IS_IN(jav$, file$)
  k = IS_IN(pkg$, buf$, -1)
  IF IS_IN(NotifLib$, MID$(buf$, k)) = 1
   k = IS_IN(pkg$, buf$, k-LEN(buf$)-2)
  ENDIF
  IF !k THEN F_N.CONTINUE
  k = IS_IN(LF$, buf$, k)
  e$ = REPLACE$(MID$(buf$, k+1), "@Override", "")
  j = IS_IN("notification.setLatestEventInfo", e$)
  IF j THEN e$ = LEFT$(e$, j-1) + "//" + MID$(e$, j)
  PutFile(e$, file$ + ".body")
  ? FileName$(file$) + ".body" + Sz$(e$)
  buf$ = LEFT$(buf$, k)
  k = IS_IN("package", buf$)
  IF k > 0 THEN buf$ = MID$(buf$, k)
  PutFile(buf$, file$ + ".head")
  ? FileName$(file$) + ".head" + Sz$(buf$)
  ? "created in " + INT$(CLOCK()-c1) + " ms."

  % Unzip all other files as is
 ELSEIF buf$ <> "EOF"
  PutFile(buf$, file$)
  ? MID$(file$, LEN(proj$)+2) + " unzipped" + Sz$(buf$)
 ENDIF
NEXT

ZIP.CLOSE zid
? proj$ + " flavor imported in " + INT$(CLOCK()-c0) + " ms."

% Make file listing
% ------------------

c1 = CLOCK()
RecursiveDir(proj$, files)
LIST.SIZE files, nfiles
buf$ = ""
FOR i = 1 TO nfiles
 LIST.GET files, i, f$
 buf$ += "../../rfo-super-user/data/" + f$ + LF$
NEXT
PutFile(buf$, proj$ + ".lst")
? "File listing done in " + INT$(CLOCK()-c1) + " ms."

% Create flavor descriptor
% -------------------------
TEXT.OPEN w, fid, proj$ + ".desc"
TEXT.WRITELN fid, pkg$
TEXT.CLOSE fid

% Done!
%-------

c0 = CLOCK() - c0
e$ = "?Flavor " + DQ$ + proj$ + DQ$ + " correctly imported in " + INT$(c0/1000) + " s"
GOSUB UpdatePgbar
showdlgm = 1
? "SUCCESS PREPARING FOLDER " + DQ$ + proj$ + DQ$
? "TOTAL TIME: " + INT$(c0) + " ms."

FinImport:
CONSOLE.SAVE proj$ + ".log"
PAUSE 2000
GOTO Flav_Menu

Flav_Config:
%----------------------------------------------
% Read the flavor settings
%----------------------------------------------
CLS % clear console
? "Welcome to " + this$
? "Getting " + proj$ + " flavor settings"

% Read Manifest
buf$ = GetFile$(proj$ + "/AndroidManifest.xml")
? "Reading AndroidManifest.xml" + Sz$(buf$)
inst$ = NxtQuote$(buf$, IS_IN("android:installLocation", buf$))
? "- installLocation: " + DQ$ + inst$ + DQ$
e$ = NxtQuote$(buf$, IS_IN("android:minSdkVersion", buf$))
sdkmin = EVAL(e$)
? "- minSdkVersion: " + INT$(sdkmin)
e$ = NxtQuote$(buf$, IS_IN("android:targetSdkVersion", buf$))
sdktgt = EVAL(e$)
? "- targetSdkVersion: " + INT$(sdktgt)

% Read Settings.xml
buf$ = GetFile$(proj$ + "/res/xml/settings.xml")
? "Reading res/xml/settings.xml" + Sz$(buf$)
i = IS_IN("es_pref", buf$)
i = IS_IN("android:defaultValue", buf$, i)
concol$ = NxtQuote$(buf$, i)
? "- Console_Color_Scheme: " + DQ$ + concol$ + DQ$
i = IS_IN("font_pref", buf$)
i = IS_IN("android:defaultValue", buf$, i)
consiz$ = NxtQuote$(buf$, i)
? "- Console_Font_Size: " + DQ$ + consiz$ + DQ$
i = IS_IN("csf_pref", buf$)
i = IS_IN("android:defaultValue", buf$, i)
contyp$ = NxtQuote$(buf$, i)
? "- Console_Font_Typeface: " + DQ$ + contyp$ + DQ$
i = IS_IN("so_pref", buf$)
i = IS_IN("android:defaultValue", buf$, i)
conori = EVAL(NxtQuote$(buf$, i))
? "- Console_Screen_Orientation: " + INT$(conori)
i = IS_IN("console_menu", buf$)
i = IS_IN("android:defaultValue", buf$, i)
conmnu$ = NxtQuote$(buf$, i)
? "- Display_Console_Menu: " + DQ$ + conmnu$ + DQ$
i = IS_IN("lined_console", buf$)
i = IS_IN("android:defaultValue", buf$, i)
conlin$ = NxtQuote$(buf$, i)
? "- Use_Lined_Console: " + DQ$ + conlin$ + DQ$

% Read Setup.xml
buf$ = GetFile$(proj$ + "/res/values/setup.xml")
? "Reading res/values/setup.xml" + Sz$(buf$)
splash$ = NxtXml$(buf$, IS_IN("splash_display", buf$))
? "- Splash_Display: " + DQ$ + splash$ + DQ$
splacol$ = NxtXml$(buf$, IS_IN("splash_color", buf$))
? "- Splash_Color: " + DQ$ + splacol$ + DQ$
splatim = EVAL(NxtXml$(buf$, IS_IN("splash_time", buf$)))
? "- Splash_Time: " + INT$(splatim)

CONSOLE.SAVE proj$ + "-config.log"

%----------------------------------------------
% Flavor config: display and populate page
%----------------------------------------------
GW_RENDER(pg_cfg)
PAUSE 100
GW_MODIFY(tb_cfg, "title", proj$)
% Modify InputMinis
GW_MODIFY(mi_sdkmin, "input", INT$(sdkmin))
GW_MODIFY(mi_sdktgt, "input", INT$(sdktgt))
GW_MODIFY(mi_splash, "input", INT$(splatim))
% Modify SelectBoxes
ARRAY.SEARCH inst$[], inst$, k
GW_MODIFY(sb_inst, "selected", INT$(k))
ARRAY.SEARCH concol2$[], concol$, k
GW_MODIFY(sb_concol, "selected", INT$(k))
ARRAY.SEARCH consiz$[], consiz$, k
GW_MODIFY(sb_consiz, "selected", INT$(k))
ARRAY.SEARCH contyp2$[], contyp$, k
GW_MODIFY(sb_contyp, "selected", INT$(k))
ARRAY.SEARCH orient2$[], INT$(conori), k
GW_MODIFY(sb_conori, "selected", INT$(k))
% Modify FlipSwitches
GW_MODIFY(sw_conmnu, "selected", conmnu$)
GW_MODIFY(sw_conlin, "selected", conlin$)
GW_MODIFY(sw_splash, "selected", splash$)
% Modify ColorPicker
GW_MODIFY(col_splash, "input", splacol$)
DO : PAUSE 100 : r$=GW_ACTION$() : UNTIL r$="" % empty event buffer due to last GW_MODIFY

%----------------------------------------------
% Flavor config: handle user input
%----------------------------------------------
DO
 r$ = GW_WAIT_ACTION$()
 IF r$ = "EXIT"
  IF IS_APK() THEN EXIT ELSE END
 ELSEIF r$ = "BACK"
  GOTO Flav_Menu
 ELSEIF r$ = "SAVE"
  GOTO Sav_Config
 ELSE
  r$ = ""
 ENDIF
UNTIL LEN(r$)

Sav_Config:
%----------------------------------------------
% Get the new flavor settings
%----------------------------------------------
sdkmin  = GW_GET_VALUE(mi_sdkmin)
sdktgt  = GW_GET_VALUE(mi_sdktgt)
splatim = GW_GET_VALUE(mi_splash)
inst$   = inst$[GW_GET_VALUE(sb_inst)]
concol$ = concol2$[GW_GET_VALUE(sb_concol)]
consiz$ = consiz$[GW_GET_VALUE(sb_consiz)]
contyp$ = contyp2$[GW_GET_VALUE(sb_contyp)]
conori  = EVAL(orient2$[GW_GET_VALUE(sb_conori)])
conmnu$ = GW_GET_VALUE$(sw_conmnu)
conlin$ = GW_GET_VALUE$(sw_conlin)
splash$ = GW_GET_VALUE$(sw_splash)
splacol$ = GW_GET_VALUE$(col_splash) % #rrggbb

%----------------------------------------------
% Write the new flavor settings
%----------------------------------------------

% Write Manifest
buf$ = GetFile$(proj$ + "/AndroidManifest.xml")
i = IS_IN("android:installLocation", buf$)
i = IS_IN(DQ$, buf$, i) : j = IS_IN(DQ$, buf$, i+1)
buf$ = LEFT$(buf$, i) + inst$ + MID$(buf$, j)
i = IS_IN("android:minSdkVersion", buf$)
i = IS_IN(DQ$, buf$, i) : j = IS_IN(DQ$, buf$, i+1)
buf$ = LEFT$(buf$, i) + INT$(sdkmin) + MID$(buf$, j)
i = IS_IN("android:targetSdkVersion", buf$)
i = IS_IN(DQ$, buf$, i) : j = IS_IN(DQ$, buf$, i+1)
buf$ = LEFT$(buf$, i) + INT$(sdktgt) + MID$(buf$, j)
PutFile(buf$, proj$ + "/AndroidManifest.xml")

% Write Settings.xml
buf$ = GetFile$(proj$ + "/res/xml/settings.xml")
i = IS_IN("es_pref", buf$)
i = IS_IN("android:defaultValue", buf$, i)
i = IS_IN(DQ$, buf$, i) : j = IS_IN(DQ$, buf$, i+1)
buf$ = LEFT$(buf$, i) + concol$ + MID$(buf$, j)
i = IS_IN("font_pref", buf$)
i = IS_IN("android:defaultValue", buf$, i)
i = IS_IN(DQ$, buf$, i) : j = IS_IN(DQ$, buf$, i+1)
buf$ = LEFT$(buf$, i) + consiz$ + MID$(buf$, j)
i = IS_IN("csf_pref", buf$)
i = IS_IN("android:defaultValue", buf$, i)
i = IS_IN(DQ$, buf$, i) : j = IS_IN(DQ$, buf$, i+1)
buf$ = LEFT$(buf$, i) + contyp$ + MID$(buf$, j)
i = IS_IN("so_pref", buf$)
i = IS_IN("android:defaultValue", buf$, i)
i = IS_IN(DQ$, buf$, i) : j = IS_IN(DQ$, buf$, i+1)
buf$ = LEFT$(buf$, i) + INT$(conori) + MID$(buf$, j)
i = IS_IN("console_menu", buf$)
i = IS_IN("android:defaultValue", buf$, i)
i = IS_IN(DQ$, buf$, i) : j = IS_IN(DQ$, buf$, i+1)
buf$ = LEFT$(buf$, i) + conmnu$ + MID$(buf$, j)
i = IS_IN("lined_console", buf$)
i = IS_IN("android:defaultValue", buf$, i)
i = IS_IN(DQ$, buf$, i) : j = IS_IN(DQ$, buf$, i+1)
buf$ = LEFT$(buf$, i) + conlin$ + MID$(buf$, j)
PutFile(buf$, proj$ + "/res/xml/settings.xml")

% Write Setup.xml
buf$ = GetFile$(proj$ + "/res/values/setup.xml")
i = IS_IN("splash_display", buf$)
i = IS_IN(">", buf$, i) : j = IS_IN("<", buf$, i+1)
buf$ = LEFT$(buf$, i) + splash$ + MID$(buf$, j)
i = IS_IN("splash_color", buf$)
i = IS_IN(">", buf$, i) : j = IS_IN("<", buf$, i+1)
buf$ = LEFT$(buf$, i) + splacol$ + MID$(buf$, j)
i = IS_IN("splash_time", buf$)
i = IS_IN(">", buf$, i) : j = IS_IN("<", buf$, i+1)
buf$ = LEFT$(buf$, i) + INT$(splatim) + MID$(buf$, j)
PutFile(buf$, proj$ + "/res/values/setup.xml")

POPUP proj$ + " successfully configured"
GOTO Flav_Menu

%----------------------------------------------
% Functions and Subs
%----------------------------------------------
DefFns:

FN.DEF Sz$(a$) % human readable file size
 a = LEN(a$)
 IF a >= 1000^2
  FN.RTN " (" + INT$(a/1000^2) + " MB)"
 ELSEIF a >= 1000
  FN.RTN " (" + INT$(a/1000) + " KB)"
 ELSE
  FN.RTN " (" + INT$(a) + " Bytes)"
 ENDIF
FN.END

FN.DEF EVAL(e$)
 IF IS_NUMBER(e$) THEN FN.RTN VAL(e$) ELSE FN.RTN 0
FN.END

FN.DEF NxtQuote$(e$, k)
 q$ = CHR$(34)
 i = IS_IN(q$, e$, k)  : IF 0=i THEN i = LEN(e$)
 j = IS_IN("'", e$, k) : IF 0=j THEN j = LEN(e$)
 IF j < i THEN i = j : q$ = "'"
 j = IS_IN(q$, e$, i+1)
 FN.RTN MID$(e$, i+1, j-i-1)
FN.END

FN.DEF NxtXml$(e$, k)
 i = IS_IN(">", e$, k) : IF 0=i THEN i = LEN(e$)
 j = IS_IN("<", e$, i) : IF 0=j THEN j = LEN(e$)
 FN.RTN MID$(e$, i+1, j-i-1)
FN.END

RETURN

ChangeTheme:
ARRAY.LOAD pages[], pg_flav, GW_PF_PAGE, pg_cfg
ARRAY.LENGTH npg, pages[]
ARRAY.LOAD thm_drk$[], "='b'", "#000", "#333", "invert(100%", "#ffff00", "#888800", "#888888"
ARRAY.LOAD thm_lit$[], "='a'", "#fff", "#ccc", "invert(0%", "#0000ff", "#aaaaff", "#aaaaaa"
ARRAY.LENGTH nth, thm_drk$[]
FOR k = 1 TO npg
 pg = pages[k]
 IF !pg THEN F_N.CONTINUE
 p$ = GW_PAGE$(pg)
 FOR j=1 TO nth
  IF drk_thm   % target = dark theme
   p$=REPLACE$(p$,thm_lit$[j],thm_drk$[j])
  ELSE         % target = light theme
   p$=REPLACE$(p$,thm_drk$[j],thm_lit$[j])
  ENDIF
 NEXT
 GW_SET_SKEY("page", pg, p$)
NEXT
RETURN

UpdatePgbar:
IF LEFT$(e$, 1) = "!"
 e$ = "<span style='color:red'>" + MID$(e$, 2) + "</span>"
ELSEIF LEFT$(e$, 1) = "?"
 e$ = "<span style='color:green'>" + MID$(e$, 2) + "</span>"
ELSEIF LEN(e$) > 42
 e$ = LEFT$(e$, 21) + "..." + RIGHT$(e$, 21)
ENDIF
e$ = "<small>" + e$ + "</small>"
GW_MODIFY(pgbar, "text", e$)
RETURN


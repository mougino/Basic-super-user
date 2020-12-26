! This is the third party lib "GW_PICK_FILE.bas"
! http://laughton.com/basic/programs/html/GW%20(GUI-Web%20lib)/
!
! This lib requires the main lib "GW.bas" and of course Android RFO-BASIC!
! To download the lib when you have "GW.bas" on your device, do:
!    GW_DOWNLOAD_THIRD_PARTY("GW_PICK_FILE.bas")
!
! USAGE: in your program do: INCLUDE "GW_PICK_FILE.bas"
! Then call: folder$ = GW_PICK_FOLDER$()
!        or:  file$  = GW_PICK_FILE$(filter$)
! where filter$ contains all the file extensions separated by comas
! e.g. ?GW_PICK_FILE$("*.java,*.c,*.bas")
!      ?GW_PICK_FILE$("*.*") (or "") for all files (no filter)

INCLUDE "GW.bas"


! Declare functions:
!== == == == == == == == == == == ==
INCLUDE "utils_str.bas"

FN.DEF SortNoCase(a$[])
 ARRAY.LENGTH al, a$[]
 FOR i=1 TO al
  FOR j=i+1 TO al
   IF LOWER$(a$[j]) < LOWER$(a$[i]) THEN SWAP a$[i], a$[j]
  NEXT
 NEXT
FN.END

FN.DEF Short$(e$,nc)
 IF RIGHT$(e$,1)="/" & e$<>"/" THEN e$=LEFT$(e$,-1)
 IF LEN(e$)>nc
  e$=LEFT$(e$,FLOOR(nc/2))+"..."+RIGHT$(e$,CEIL(nc/2))
 ENDIF
 FN.RTN e$
FN.END

FN.DEF FileNameIsSafe(e$)
 safe=1
 FOR i=1 TO 31
  IF IS_IN(CHR$(i),e$) THEN safe=0: F_N.BREAK
 NEXT
 FN.RTN safe
FN.END

FN.DEF FinishWith(file$, ext$)
 IF ext$="" | IS_IN(".*",ext$) THEN FN.RTN 1
 ext$=REPLACE$(ext$, "*.", ".")
 IF IS_IN(",", ext$) THEN SPLIT ext$[], ext$, "," ELSE ARRAY.LOAD ext$[], ext$
 ARRAY.LENGTH noe, ext$[]
 FOR i=1 TO noe
  IF LOWER$(RIGHT$(file$, LEN(ext$[i])))=LOWER$(ext$[i]) THEN found=1 : F_N.BREAK
 NEXT
 FN.RTN found
FN.END

FN.DEF ListFiles(path$, extensions$, list) % use extensions$="/" to list folders
 FILE.ROOT sd$
 root$=BUILD$("../", TALLY(sd$, "/"))
 FOR i=1 TO 2: sd$=LEFT$(sd$, IS_IN("/", sd$, -2)): NEXT
 FILE.DIR root$+LTRIM$(path$,"/"), all$[], "/" % list all folders + files
 ARRAY.LENGTH nall, all$[]
 FOR nfolders=1 TO nall % find separation folders/files
  IF RIGHT$(all$[nfolders],1)<>"/" THEN F_N.BREAK % found first file > everything before are folders
 NEXT
 IF --nfolders=0 & IS_IN(path$, sd$) % fix for Lollipop
  e$=REPLACE$(sd$, path$, "") + "/"
  ARRAY.LOAD all$[], LEFT$(e$, IS_IN("/",e$))
  nfolders++
 ENDIF
 LIST.CLEAR list
 IF nfolders>0
  ARRAY.COPY all$[1, nfolders], folders$[]
  SortNoCase(folders$[]) % sort regardless of case: aAbBcC...xXyYzZ
  LIST.ADD.ARRAY list, folders$[]
  FOR i=1 TO nfolders
   IF LEFT$(folders$[i],1)="." THEN cl$="hfo" ELSE cl$="fo" % show differently hidden (system) folders
   e$ = "&#x1f4c1; <span class='" + cl$ + "'>"
   e$ += LTRIM$(LEFT$(folders$[i], -1), root$)
   e$ += "</span> >^" + folders$[i]
   LIST.REPLACE list, i, e$
  NEXT
 ENDIF
 IF extensions$<>"/" & nall<>nfolders & LEN(all$[nall]) % now go through the files
  ARRAY.COPY all$[nfolders+1], files$[]
  SortNoCase(files$[])
  LIST.ADD.ARRAY list, files$[]
  FOR i=nall-nfolders TO 1 STEP -1
   IF !FileNameIsSafe(files$[i]) | !FinishWith(files$[i], extensions$)
    LIST.REMOVE list, nfolders+i
    F_N.CONTINUE
   ENDIF
   IF LEFT$(files$[i],1)="." THEN cl$="hfi" ELSE cl$="" % show differently hidden (system) files
   e$ = "&#x1f4c4; "
   IF LEN(cl$) THEN e$ += "<span class='" + cl$ + "'>"
   e$ += LTRIM$(files$[i], root$)
   IF LEN(cl$) THEN e$ += "</span>"
   e$ += ">^" + files$[i]
   LIST.REPLACE list, nfolders+i, e$
  NEXT
 ENDIF
 IF TALLY(path$, "/") > 2 THEN LIST.INSERT list, 1, "..>^.." % add parent folder ".." if we can
FN.END


FN.DEF GW_PICK_FILE$(filter$)
 ! Init
 !== == == == == == == == == == == ==
 BUNDLE.GET 1, "GW_PF_PAGE", GW_PF_PAGE
 BUNDLE.GET 1, "GW_PF_TB", GW_PF_TB
 BUNDLE.GET 1, "GW_PF_LV", GW_PF_LV
 BUNDLE.GET 1, "GW_FOLDER", GW_FOLDER$
 BUNDLE.GET 1, "HISTO", HISTO
 LIST.CREATE s, GW_FILES
 GOSUB GW_PF_UPDATE
 ! Main Loop
 !== == == == == == == == == == == ==
 GW_PFI_LOOP:
  r$=GW_WAIT_ACTION$()
  IF r$="CANCEL"
   FN.RTN ""
  ELSEIF LEFT$(r$,1)="^"
   IF r$="^.."
    STACK.PUSH HISTO, GW_FOLDER$
    GW_FOLDER$=LEFT$(GW_FOLDER$, IS_IN("/", GW_FOLDER$, -2))
   ELSEIF RIGHT$(r$, 1)="/"
    STACK.PUSH HISTO, GW_FOLDER$
    GW_FOLDER$+=MID$(r$,2)
   ELSE % user picked a file
    BUNDLE.PUT 1, "GW_FOLDER", GW_FOLDER$
    FILE.ROOT sd$ % return relative path
    root$=BUILD$("../", TALLY(sd$, "/"))
    FN.RTN root$+LTRIM$(GW_FOLDER$,"/")+MID$(r$,2)
   ENDIF
   GOSUB GW_PF_UPDATE
  ELSEIF r$="SEL" % user picked a folder
    BUNDLE.PUT 1, "GW_FOLDER", GW_FOLDER$
    FILE.ROOT sd$ % return relative path
    root$=BUILD$("../", TALLY(sd$, "/"))
    FN.RTN root$+LTRIM$(GW_FOLDER$,"/")
  ELSEIF r$="BACK"
   STACK.ISEMPTY HISTO, empty
   IF !empty
    STACK.POP HISTO, GW_FOLDER$
    GOSUB GW_PF_UPDATE
   ELSEIF ++BackTapped=1
    IF filter$="/" THEN e$="Folder" ELSE e$="File"
    POPUP "Tap Back key again\n  to exit "+e$+" Picker"
   ELSE % user tapped Back key twice with no histo > exit
    FN.RTN ""
   ENDIF
  ENDIF
 GOTO GW_PFI_LOOP
 ! Update SUB
 !== == == == == == == == == == == ==
 GW_PF_UPDATE:
 BackTapped=0
 ListFiles(GW_FOLDER$, filter$, GW_FILES)
 UNDIM GW_FILES$[]
 LIST.TOARRAY GW_FILES, GW_FILES$[]
 LIST.CLEAR GW_FILES
 IF !main_page_displayed
  GW_RENDER(GW_PF_PAGE)
  IF filter$<>"/" THEN JS("$('.ui-btn-right').hide()") % keep "select" button only in folder picker
  main_page_displayed=1
 ENDIF
 GW_MODIFY(GW_PF_TB, "title", Short$(GW_FOLDER$,24))
 GW_AMODIFY(GW_PF_LV, "content", GW_FILES$[])
 RETURN
FN.END

FN.DEF GW_PICK_FOLDER$()
  FN.RTN GW_PICK_FILE$("/")
FN.END


! GW_PICK_FILE/FOLDER Page Definition:
!== == == == == == == == == == == == ==
GW_PF_PAGE=GW_NEW_PAGE()
GW_USE_THEME_CUSTO_ONCE("iconpos=notext icon=back")
lbar$=GW_ADD_BAR_LBUTTON$(">CANCEL")
rbar$=GW_ADD_BAR_RBUTTON$("Select>SEL")
GW_PF_TB=GW_ADD_TITLEBAR(GW_PF_PAGE, lbar$+GW_ADD_BAR_TITLE$(GW_FOLDER$)+rbar$)
ARRAY.LOAD GW_FOLDERS$[], ".."
GW_PF_LV=GW_ADD_LISTVIEW(GW_PF_PAGE, GW_FOLDERS$[])
GW_INJECT_HTML(GW_PF_PAGE, "<style>.fo{color:#0000ff} .hfo{color:#aaaaff} .hfi{color:#aaaaaa}</style>")

FILE.ROOT GW_FOLDER$
FOR i=1 TO 2 % start at /sdcard i.e. myapp/data/../..
  GW_FOLDER$=LEFT$(GW_FOLDER$, IS_IN("/", GW_FOLDER$, -2))
NEXT
STACK.CREATE s, HISTO

BUNDLE.PUT 1, "GW_PF_PAGE", GW_PF_PAGE
BUNDLE.PUT 1, "GW_PF_TB", GW_PF_TB
BUNDLE.PUT 1, "GW_PF_LV", GW_PF_LV
BUNDLE.PUT 1, "GW_FOLDER", GW_FOLDER$
BUNDLE.PUT 1, "HISTO", HISTO


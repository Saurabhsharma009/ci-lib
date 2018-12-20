*---------------------------------------------------------------------*
*    view related FORM routines
*   generation date: 17.12.2018 at 19:13:31
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZCILIB_HOST_V...................................*
FORM GET_DATA_ZCILIB_HOST_V.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZCILIB_HOST WHERE
(VIM_WHERETAB) .
    CLEAR ZCILIB_HOST_V .
ZCILIB_HOST_V-CLIENT =
ZCILIB_HOST-CLIENT .
ZCILIB_HOST_V-HOST =
ZCILIB_HOST-HOST .
ZCILIB_HOST_V-DESTINATION =
ZCILIB_HOST-DESTINATION .
ZCILIB_HOST_V-BOT_IMPL =
ZCILIB_HOST-BOT_IMPL .
<VIM_TOTAL_STRUC> = ZCILIB_HOST_V.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZCILIB_HOST_V .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZCILIB_HOST_V.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZCILIB_HOST_V-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZCILIB_HOST WHERE
  HOST = ZCILIB_HOST_V-HOST .
    IF SY-SUBRC = 0.
    DELETE ZCILIB_HOST .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZCILIB_HOST WHERE
  HOST = ZCILIB_HOST_V-HOST .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZCILIB_HOST.
    ENDIF.
ZCILIB_HOST-CLIENT =
ZCILIB_HOST_V-CLIENT .
ZCILIB_HOST-HOST =
ZCILIB_HOST_V-HOST .
ZCILIB_HOST-DESTINATION =
ZCILIB_HOST_V-DESTINATION .
ZCILIB_HOST-BOT_IMPL =
ZCILIB_HOST_V-BOT_IMPL .
    IF SY-SUBRC = 0.
    UPDATE ZCILIB_HOST ##WARN_OK.
    ELSE.
    INSERT ZCILIB_HOST .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZCILIB_HOST_V-UPD_FLAG,
STATUS_ZCILIB_HOST_V-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZCILIB_HOST_V.
  SELECT SINGLE * FROM ZCILIB_HOST WHERE
HOST = ZCILIB_HOST_V-HOST .
ZCILIB_HOST_V-CLIENT =
ZCILIB_HOST-CLIENT .
ZCILIB_HOST_V-HOST =
ZCILIB_HOST-HOST .
ZCILIB_HOST_V-DESTINATION =
ZCILIB_HOST-DESTINATION .
ZCILIB_HOST_V-BOT_IMPL =
ZCILIB_HOST-BOT_IMPL .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZCILIB_HOST_V USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZCILIB_HOST_V-HOST TO
ZCILIB_HOST-HOST .
MOVE ZCILIB_HOST_V-CLIENT TO
ZCILIB_HOST-CLIENT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZCILIB_HOST'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZCILIB_HOST TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZCILIB_HOST'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*

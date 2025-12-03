*&---------------------------------------------------------------------*
*& Report ZKK_SAPSCRIPT_DRIVER_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkk_sapscript_driver.

PARAMETERS: p_ebeln TYPE ekko-ebeln.

TYPES: BEGIN OF ty_header,
         butxt  TYPE t001-butxt,
         ort01  TYPE t001-ort01,
         land1  TYPE t001-land1,
         ebeln  TYPE ekko-ebeln,
         aedat  TYPE ekko-aedat,
         ernam  TYPE ekko-ernam,
         zterm  TYPE ekko-zterm,
         verkf  TYPE ekko-verkf,
         telf1  TYPE ekko-telf1,
         waers  TYPE ekko-waers,
         wkurs  TYPE ekko-wkurs,
         lifnr  TYPE lfa1-lifnr,
         vname1 TYPE lfa1-name1,
         vort01 TYPE lfa1-ort01,
         vort02 TYPE lfa1-ort02,
       END OF ty_header.

TYPES: BEGIN OF ty_item,
         ebelp    TYPE ekpo-ebelp,
         txz01    TYPE ekpo-txz01,
         matnr    TYPE ekpo-matnr,
         descript TYPE makt-maktx,
         menge    TYPE ekpo-menge,
         netpr    TYPE ekpo-netpr,
         netval   TYPE ekpo-netpr,
         meins    TYPE ekpo-meins,
         comment  TYPE ekpo-zzkk_comment,
       END OF ty_item.

TYPES: BEGIN OF ty_tab_header,
         ebelp    TYPE char20,
         txz01    TYPE char20,
         matnr    TYPE char20,
         descript TYPE char20,
         menge    TYPE char20,
         netpr    TYPE char20,
         netval   TYPE char20,
         comment  TYPE char20,
       END OF ty_tab_header.

TYPES: BEGIN OF ty_output,
         ebelp    TYPE string,
         txz01    TYPE string,
         matnr    TYPE string,
         descript TYPE string,
         menge    TYPE char20,
         netpr    TYPE string,
         netval   TYPE string,
         comment  TYPE string,
         new_row  TYPE abap_bool,
       END OF ty_output.

DATA: gs_header     TYPE ty_header,
      gt_item       TYPE STANDARD TABLE OF ty_item,
      gs_item       TYPE ty_item,
      gv_date       TYPE char10,
      gv_time       TYPE char8,
      gv_ypos       TYPE p DECIMALS 2,
      gt_tab_header TYPE STANDARD TABLE OF ty_tab_header,
      gs_tab        TYPE ty_tab_header,
      gt_output     TYPE STANDARD TABLE OF ty_output,
      gs_output     TYPE ty_output,
      gs_lines      TYPE tline,
      gv_total      TYPE ekpo-netpr.

PERFORM get_data.
PERFORM open_form.
PERFORM write_form_header.
PERFORM write_table_header.
PERFORM write_table_cells.
PERFORM write_footer.
PERFORM close_form.


FORM write_table_cells.
  DATA: lv_max_rows     TYPE i,
        lv_index        TYPE i,
        lv_tabix        TYPE i,
        lv_ypos         TYPE p DECIMALS 2,
        lv_height       TYPE p DECIMALS 2,
        lv_cmd          TYPE string,
        lv_win_height   TYPE p DECIMALS 1,
        lt_lines        TYPE TABLE OF swastrtab,
        lv_display_line TYPE i.


  lv_ypos = 10.
  lv_win_height = '100'.

  MOVE-CORRESPONDING gt_item TO gt_output.

  LOOP AT gt_output INTO gs_output WHERE ebelp IS NOT INITIAL.

    lv_display_line = sy-tabix.
    lv_tabix = sy-tabix.
    DATA(lv_ebelp) = gs_output-ebelp.

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string         = gs_output-txz01
        max_component_length = 10
      TABLES
        string_components    = lt_lines.
    IF sy-subrc = 0.

      DATA(lv_rows) = lines( lt_lines ).

      IF lv_max_rows IS INITIAL.
        lv_max_rows = lv_rows.
      ENDIF.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows < lv_rows.

        lv_max_rows = lv_rows.

      ENDIF.

      IF lv_rows = 1.

        CLEAR lt_lines.

      ELSE.

        lv_index = 1.

        LOOP AT lt_lines INTO DATA(ls_lines).

          IF sy-tabix  = 1.

            CLEAR gs_output.
            gs_output-txz01 = ls_lines-str.
            MODIFY gt_output FROM gs_output INDEX lv_tabix TRANSPORTING txz01.

            CONTINUE.

          ENDIF.

          READ TABLE gt_output INTO gs_output INDEX lv_tabix + lv_index.

          IF sy-subrc <> 0.

            CLEAR gs_output.
            gs_output-txz01 = ls_lines-str.
            gs_output-new_row = abap_true.
            INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

          ELSE.

            IF gs_output-new_row = abap_false AND gs_output-ebelp <> lv_ebelp.

              CLEAR gs_output.
              gs_output-txz01 = ls_lines-str.
              gs_output-new_row = abap_true.
              INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

            ELSEIF gs_output-new_row = abap_true.

              CLEAR gs_output.
              gs_output-txz01 = ls_lines-str.
              MODIFY gt_output FROM gs_output INDEX lv_tabix + lv_index TRANSPORTING txz01.

            ENDIF.

          ENDIF.

          lv_index += 1.

        ENDLOOP.

      ENDIF.

      CLEAR: lv_rows, lt_lines, ls_lines, gs_output.

      lv_index = 0.

    ENDIF.

    READ TABLE gt_output INTO gs_output INDEX lv_tabix.

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string         = gs_output-matnr
        max_component_length = 6
      TABLES
        string_components    = lt_lines.
    IF sy-subrc = 0.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows IS INITIAL.
        lv_max_rows = lv_rows.
      ENDIF.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows < lv_rows.

        lv_max_rows = lv_rows.

      ENDIF.

      IF lv_rows = 1.

        CLEAR lt_lines.

      ELSE.

        lv_index = 1.

        LOOP AT lt_lines INTO ls_lines.

          IF sy-tabix  = 1.

            CLEAR gs_output.
            gs_output-matnr = ls_lines-str.
            MODIFY gt_output FROM gs_output INDEX lv_tabix TRANSPORTING matnr.

            CONTINUE.

          ENDIF.

          READ TABLE gt_output INTO gs_output INDEX lv_tabix + lv_index.

          IF sy-subrc <> 0.

            CLEAR gs_output.
            gs_output-matnr = ls_lines-str.
            gs_output-new_row = abap_true.
            INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

          ELSE.

            IF gs_output-new_row = abap_false AND gs_output-ebelp <> lv_ebelp.

              CLEAR gs_output.
              gs_output-matnr = ls_lines-str.
              gs_output-new_row = abap_true.
              INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

            ELSEIF gs_output-new_row = abap_true.

              CLEAR gs_output.
              gs_output-matnr = ls_lines-str.
              MODIFY gt_output FROM gs_output INDEX lv_tabix + lv_index TRANSPORTING matnr.

            ENDIF.

          ENDIF.

          lv_index += 1.

        ENDLOOP.

      ENDIF.

      CLEAR: lv_rows, lt_lines, ls_lines, gs_output.

      lv_index = 0.

    ENDIF.

    READ TABLE gt_output INTO gs_output INDEX lv_tabix.

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string         = gs_output-descript
        max_component_length = 10
      TABLES
        string_components    = lt_lines.
    IF sy-subrc = 0.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows IS INITIAL.
        lv_max_rows = lv_rows.
      ENDIF.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows < lv_rows.

        lv_max_rows = lv_rows.

      ENDIF.

      IF lv_rows = 1.

        CLEAR lt_lines.

      ELSE.

        lv_index = 1.

        LOOP AT lt_lines INTO ls_lines.

          IF sy-tabix  = 1.

            CLEAR gs_output.
            gs_output-descript = ls_lines-str.
            MODIFY gt_output FROM gs_output INDEX lv_tabix TRANSPORTING descript.

            CONTINUE.

          ENDIF.

          READ TABLE gt_output INTO gs_output INDEX lv_tabix + lv_index.

          IF sy-subrc <> 0.

            CLEAR gs_output.
            gs_output-descript = ls_lines-str.
            gs_output-new_row = abap_true.
            INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

          ELSE.

            IF gs_output-new_row = abap_false AND gs_output-ebelp <> lv_ebelp.

              CLEAR gs_output.
              gs_output-descript = ls_lines-str.
              gs_output-new_row = abap_true.
              INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

            ELSEIF gs_output-new_row = abap_true.

              CLEAR gs_output.
              gs_output-descript = ls_lines-str.
              MODIFY gt_output FROM gs_output INDEX lv_tabix + lv_index TRANSPORTING descript.

            ENDIF.

          ENDIF.

          lv_index += 1.

        ENDLOOP.

      ENDIF.

      CLEAR: lv_rows, lt_lines, ls_lines, gs_output.

      lv_index = 0.

    ENDIF.

    READ TABLE gt_output INTO gs_output INDEX lv_tabix.

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string         = gs_output-comment
        max_component_length = 8
      TABLES
        string_components    = lt_lines.
    IF sy-subrc = 0.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows IS INITIAL.
        lv_max_rows = lv_rows.
      ENDIF.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows < lv_rows.

        lv_max_rows = lv_rows.

      ENDIF.

      IF lv_rows = 1.

        CLEAR lt_lines.

      ELSE.

        lv_index = 1.

        LOOP AT lt_lines INTO ls_lines.

          IF sy-tabix  = 1.

            CLEAR gs_output.
            gs_output-comment = ls_lines-str.
            MODIFY gt_output FROM gs_output INDEX lv_tabix TRANSPORTING comment.

            CONTINUE.

          ENDIF.

          READ TABLE gt_output INTO gs_output INDEX lv_tabix + lv_index.

          IF sy-subrc <> 0.

            CLEAR gs_output.
            gs_output-comment = ls_lines-str.
            gs_output-new_row = abap_true.
            INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

          ELSE.

            IF gs_output-new_row = abap_false AND gs_output-ebelp <> lv_ebelp.

              CLEAR gs_output.
              gs_output-comment = ls_lines-str.
              gs_output-new_row = abap_true.
              INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

            ELSEIF gs_output-new_row = abap_true.

              CLEAR gs_output.
              gs_output-comment = ls_lines-str.
              MODIFY gt_output FROM gs_output INDEX lv_tabix + lv_index TRANSPORTING comment.

            ENDIF.

          ENDIF.

          lv_index += 1.

        ENDLOOP.

      ENDIF.

      CLEAR: lv_rows, lt_lines, ls_lines, gs_output.

      lv_index = 0.

    ENDIF.

    lv_height = '5.23' * lv_max_rows.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element  = 'TABLE_CELLS'
        function = 'APPEND'
        type     = 'BODY'
        window   = 'MAIN'
      EXCEPTIONS
        OTHERS   = 10.

    IF lv_ypos + lv_height <= lv_win_height.

      lv_cmd = |BOX XPOS '0' MM YPOS '{ lv_ypos }' MM WIDTH '13' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '13' MM YPOS '{ lv_ypos }' MM WIDTH '28' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '41' MM YPOS '{ lv_ypos }' MM WIDTH '25' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '66' MM YPOS '{ lv_ypos }' MM WIDTH '27' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '93' MM YPOS '{ lv_ypos }' MM WIDTH '21' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '114' MM YPOS '{ lv_ypos }' MM WIDTH '23' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '137' MM YPOS '{ lv_ypos }' MM WIDTH '23' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '160' MM YPOS '{ lv_ypos }' MM WIDTH '20' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      DO lv_max_rows TIMES.

        READ TABLE gt_output INTO gs_output INDEX lv_display_line.

        IF gs_output-ebelp IS NOT INITIAL.
          READ TABLE gt_item   INTO gs_item INDEX lv_display_line.
          WRITE gs_item-menge UNIT gs_item-meins TO gs_output-menge.
        ENDIF.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element  = 'TABLE_VALUES'
            function = 'SET'
            type     = 'BODY'
            window   = 'MAIN'
          EXCEPTIONS
            OTHERS   = 10.

        lv_display_line += 1.

      ENDDO.

      lv_ypos += lv_height.

    ELSE.

      lv_win_height = '200'.

      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = 'NEW-PAGE'.

      lv_ypos = 0.

      lv_cmd = |BOX XPOS '0' MM YPOS '{ lv_ypos }' MM WIDTH '13' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '13' MM YPOS '{ lv_ypos }' MM WIDTH '28' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '41' MM YPOS '{ lv_ypos }' MM WIDTH '25' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '66' MM YPOS '{ lv_ypos }' MM WIDTH '27' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '93' MM YPOS '{ lv_ypos }' MM WIDTH '21' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '114' MM YPOS '{ lv_ypos }' MM WIDTH '23' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '137' MM YPOS '{ lv_ypos }' MM WIDTH '23' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '160' MM YPOS '{ lv_ypos }' MM WIDTH '20' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.


      DO lv_max_rows TIMES.

        READ TABLE gt_output INTO gs_output INDEX lv_display_line.

        IF gs_output-ebelp IS NOT INITIAL.
          READ TABLE gt_item   INTO gs_item INDEX lv_display_line.
          WRITE gs_item-menge UNIT gs_item-meins TO gs_output-menge.
        ENDIF.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element  = 'TABLE_VALUES'
            function = 'SET'
            type     = 'BODY'
            window   = 'MAIN'
          EXCEPTIONS
            OTHERS   = 10.

        lv_display_line += 1.

      ENDDO.

      lv_ypos += lv_height.

    ENDIF.

  ENDLOOP.

  LOOP AT gt_output INTO gs_output.

    gv_total = gv_total + gs_output-netval.

  ENDLOOP.

  lv_height = '5'.

  IF lv_ypos + lv_height <= lv_win_height.
    lv_cmd = |BOX XPOS '0' MM YPOS '{ lv_ypos }' MM WIDTH '137' MM HEIGHT '5' MM FRAME 05 TW|.
    CALL FUNCTION 'CONTROL_FORM'
      EXPORTING
        command = lv_cmd
      EXCEPTIONS
        OTHERS  = 1.

    lv_cmd = |BOX XPOS '137' MM YPOS '{ lv_ypos }' MM WIDTH '43' MM HEIGHT '5' MM FRAME 05 TW|.
    CALL FUNCTION 'CONTROL_FORM'
      EXPORTING
        command = lv_cmd
      EXCEPTIONS
        OTHERS  = 1.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element                  = 'TABLE_TOTAL'
      function                 = 'APPEND'
      window                   = 'MAIN'
    EXCEPTIONS
      element                  = 1
      function                 = 2
      type                     = 3
      unopened                 = 4
      unstarted                = 5
      window                   = 6
      bad_pageformat_for_print = 7
      spool_error              = 8
      codepage                 = 9
      OTHERS                   = 10.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


  DATA: gt_lines TYPE TABLE OF tline,
        lv_name  TYPE thead-tdname.

  lv_name =  p_ebeln.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'F01'
      language                = sy-langu
      name                    = lv_name
      object                  = 'EKKO'
    TABLES
      lines                   = gt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  LOOP AT gt_lines INTO gs_lines.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element                  = 'READ_TEXT'
        window                   = 'MAIN'
      EXCEPTIONS
        element                  = 1
        function                 = 2
        type                     = 3
        unopened                 = 4
        unstarted                = 5
        window                   = 6
        bad_pageformat_for_print = 7
        spool_error              = 8
        codepage                 = 9
        OTHERS                   = 10.
    IF sy-subrc <> 0.
*    RETURN.
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM write_footer.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window                   = 'FOOTER'
    EXCEPTIONS
      element                  = 1
      function                 = 2
      type                     = 3
      unopened                 = 4
      unstarted                = 5
      window                   = 6
      bad_pageformat_for_print = 7
      spool_error              = 8
      codepage                 = 9
      OTHERS                   = 10.
  IF sy-subrc <> 0.
*  RETURN.
  ENDIF.
ENDFORM.

FORM close_form.
  CALL FUNCTION 'CLOSE_FORM'
    EXCEPTIONS
      unopened                 = 1
      bad_pageformat_for_print = 2
      send_error               = 3
      spool_error              = 4
      codepage                 = 5
      OTHERS                   = 6.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
FORM get_data.

  CONCATENATE sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum(4)
    INTO gv_date.

  CONCATENATE sy-uzeit(2) ':' sy-uzeit+2(2) ':' sy-uzeit+4(2)
    INTO gv_time.

  SELECT SINGLE  t001~butxt,
                 t001~ort01,
                 t001~land1,
                 ekko~ebeln,
                 ekko~aedat,
                 ekko~ernam,
                 ekko~zterm,
                 ekko~verkf,
                 ekko~telf1,
                 ekko~waers,
                 ekko~wkurs,
                 lfa1~lifnr,
                 lfa1~name1 AS vname1,
                 lfa1~ort01 AS vort01,
                 lfa1~ort02 AS vort02
     INTO CORRESPONDING FIELDS OF @gs_header
     FROM ekko
     LEFT JOIN t001 ON t001~bukrs = ekko~bukrs
     LEFT JOIN lfa1 ON lfa1~lifnr = ekko~lifnr
     WHERE ekko~ebeln = @p_ebeln.

  IF sy-subrc <> 0.
    MESSAGE 'Purchase Order not found' TYPE 'E'.
    RETURN.
  ENDIF.

  SELECT
      ekpo~ebelp,
      ekpo~txz01,
      ekpo~matnr,
      ekpo~menge,
      ekpo~netpr,
      ekpo~menge * ekpo~netpr AS netval,
      ekpo~meins,
      ekpo~zzkk_comment AS comment,
      makt~maktx AS descript
    FROM ekpo
    LEFT JOIN makt
      ON makt~matnr = ekpo~matnr
     AND makt~spras = @sy-langu
    INTO CORRESPONDING FIELDS OF TABLE @gt_item
    WHERE ekpo~ebeln = @p_ebeln
     ORDER BY ekpo~ebelp.

ENDFORM.

FORM open_form.
  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      form                        = 'ZKK_SAPSCRIPT'
    EXCEPTIONS
      canceled                    = 1
      device                      = 2
      form                        = 3
      options                     = 4
      unclosed                    = 5
      mail_options                = 6
      archive_error               = 7
      invalid_fax_number          = 8
      more_params_needed_in_batch = 9
      spool_error                 = 10
      codepage                    = 11
      OTHERS                      = 12.
  IF sy-subrc <> 0.
*  RETURN.
  ENDIF.
ENDFORM.

FORM write_form_header.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window                   = 'HEADER'
    EXCEPTIONS
      element                  = 1
      function                 = 2
      type                     = 3
      unopened                 = 4
      unstarted                = 5
      window                   = 6
      bad_pageformat_for_print = 7
      spool_error              = 8
      codepage                 = 9
      OTHERS                   = 10.
  IF sy-subrc <> 0.
*  RETURN.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window                   = 'ORDINFO'
    EXCEPTIONS
      element                  = 1
      function                 = 2
      type                     = 3
      unopened                 = 4
      unstarted                = 5
      window                   = 6
      bad_pageformat_for_print = 7
      spool_error              = 8
      codepage                 = 9
      OTHERS                   = 10.
  IF sy-subrc <> 0.
*  RETURN.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window                   = 'VENDOR'
    EXCEPTIONS
      element                  = 1
      function                 = 2
      type                     = 3
      unopened                 = 4
      unstarted                = 5
      window                   = 6
      bad_pageformat_for_print = 7
      spool_error              = 8
      codepage                 = 9
      OTHERS                   = 10.
  IF sy-subrc <> 0.
*  RETURN.
  ENDIF.
ENDFORM.

FORM write_table_header.

  gt_tab_header = VALUE #( ( ebelp = 'Item' txz01 = 'Description' matnr = 'Material' descript = 'Material' menge = 'Quantity' netpr = 'Net' netval = 'Net' comment = 'Comment' )
                         ( descript = 'Descr.' netpr = 'Price' netval = 'Value' ) ).

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element                  = 'TABLE_HEADER'
      window                   = 'MAIN'
    EXCEPTIONS
      element                  = 1
      function                 = 2
      type                     = 3
      unopened                 = 4
      unstarted                = 5
      window                   = 6
      bad_pageformat_for_print = 7
      spool_error              = 8
      codepage                 = 9
      OTHERS                   = 10.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


  LOOP AT gt_tab_header INTO gs_tab.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element                  = 'TABLE_HEADNAMES'
        window                   = 'MAIN'
      EXCEPTIONS
        element                  = 1
        function                 = 2
        type                     = 3
        unopened                 = 4
        unstarted                = 5
        window                   = 6
        bad_pageformat_for_print = 7
        spool_error              = 8
        codepage                 = 9
        OTHERS                   = 10.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDLOOP.

ENDFORM.

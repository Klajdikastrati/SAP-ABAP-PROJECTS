*&---------------------------------------------------------------------*
*& Report ZKK_IMAGE_DISPLAY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkk_image_display.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

  PARAMETERS: rb_upld RADIOBUTTON GROUP rb1 DEFAULT 'X' USER-COMMAND uc1,
              rb_web  RADIOBUTTON GROUP rb1.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.

  PARAMETERS: p_file TYPE w3objid MODIF ID upl,
              p_url  TYPE string  MODIF ID web LOWER CASE.

SELECTION-SCREEN END OF BLOCK b2.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    CASE abap_true.
      WHEN rb_upld.
        IF screen-group1 = 'WEB'.
          screen-active = 0.
          screen-invisible = 1.
        ELSEIF screen-group1 = 'UPL'.
          screen-active = 1.
          screen-invisible = 0.
        ENDIF.
      WHEN rb_web.
        IF screen-group1 = 'UPL'.
          screen-active = 0.
          screen-invisible = 1.
        ELSEIF screen-group1 = 'WEB'.
          screen-active = 1.
          screen-invisible = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

CLASS lcl_report DEFINITION.
  PUBLIC SECTION.

    METHODS execute.

  PRIVATE SECTION.

    METHODS upload.
    METHODS web.

    DATA: mo_container TYPE REF TO cl_gui_custom_container.

ENDCLASS.

INITIALIZATION.

  DATA: ok_code   TYPE sy-ucomm,
        go_report TYPE REF TO lcl_report.

CLASS lcl_report IMPLEMENTATION.

  METHOD upload.

    DATA: lo_picture TYPE REF TO cl_gui_picture,
          lv_url     TYPE cndp_url.

    IF mo_container IS INITIAL.
      CREATE OBJECT mo_container
        EXPORTING
          container_name              = 'CONT'
          repid                       = 'ZKK_IMAGE_DISPLAY'
          dynnr                       = '0100'
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5
          OTHERS                      = 6.
      IF sy-subrc <> 0.
        MESSAGE i001(00) WITH 'Error while creating container'.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.

    IF lo_picture IS INITIAL.
      CREATE OBJECT lo_picture
        EXPORTING
          parent = mo_container
        EXCEPTIONS
          error  = 1
          OTHERS = 2.
      IF sy-subrc <> 0.
        MESSAGE i001(00) WITH 'Error while displaying picture'.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.

    IF lo_picture IS NOT INITIAL.

      CALL FUNCTION 'DP_PUBLISH_WWW_URL'
        EXPORTING
          objid    = p_file
          lifetime = cndp_lifetime_transaction
        IMPORTING
          url      = lv_url
        EXCEPTIONS
          OTHERS   = 1.

      IF sy-subrc = 0.
        CALL METHOD lo_picture->load_picture_from_url_async
          EXPORTING
            url = lv_url.

        CALL METHOD lo_picture->set_display_mode
          EXPORTING
            display_mode = cl_gui_picture=>display_mode_fit.
      ELSE.
        MESSAGE i001(00) WITH 'Error while load picture'.
        LEAVE LIST-PROCESSING.
      ENDIF.

    ENDIF.

    CALL SCREEN 100.
  ENDMETHOD.

  METHOD web.

    DATA: lo_html_viewer TYPE REF TO cl_gui_html_viewer,
          lv_url         TYPE swk_url,
          it_html        TYPE html_table.

    IF mo_container IS INITIAL.
      CREATE OBJECT mo_container
        EXPORTING
          container_name = 'CONT'.
    ENDIF.

    IF lo_html_viewer IS INITIAL.
      CREATE OBJECT lo_html_viewer
        EXPORTING
          parent = mo_container.
    ENDIF.

    it_html = VALUE  #(  ( |<html>                               | )
                         ( |  <body>                             | )
                         ( |    <img src="{ p_url }" alt="Image">| )
                         ( |  </body>                            | )
                         ( |</html>                              | ) ).

    lo_html_viewer->load_data( IMPORTING
                         assigned_url = lv_url
                       CHANGING
                         data_table   = it_html ).

    lo_html_viewer->show_url( url = lv_url ).

    CALL SCREEN 100.
  ENDMETHOD.

  METHOD execute.

    CASE abap_true.
      WHEN rb_upld.
        upload( ).
      WHEN rb_web.
        web( ).
    ENDCASE.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

    IF rb_upld = abap_true.
    SELECT SINGLE objid FROM wwwparams
      INTO @DATA(lv_dummy)
      WHERE objid = @p_file.
    IF sy-subrc <> 0.
      MESSAGE 'MIME Object not found' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
  ENDIF.

  go_report = NEW #( ).
  go_report->execute( ).

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'ZSTATUS'.
  SET TITLEBAR 'IMAGE DISPLAY'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'FC_BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.

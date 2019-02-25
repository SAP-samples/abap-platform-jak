CLASS zcl_jak_data_in DEFINITION INHERITING FROM zcl_jak_data
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES: zif_jak_data_in.
    CLASS-METHODS:
      initialize_with_http_request IMPORTING i_http_request    TYPE REF TO if_web_http_request
                                   RETURNING VALUE(r_jak_data) TYPE REF TO zif_jak_data_in,
      initialize_with_json         IMPORTING i_json            TYPE string
                                   RETURNING VALUE(r_jak_data) TYPE REF TO zif_jak_data_in.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: data_service TYPE REF TO zcl_yy_data_service.
    CLASS-METHODS: handle_http_request IMPORTING i_http_request TYPE REF TO if_web_http_request
                                       EXPORTING e_status       TYPE zif_jak_data=>ty_s_jak_status
                                                 e_raw_text     TYPE string.
    METHODS:
      constructor IMPORTING i_raw_text       TYPE string
                            i_current_status TYPE zif_jak_data=>ty_s_jak_status,
      fill_with_data_element IMPORTING i_current_data_element TYPE REF TO zif_yy_data_element
                             CHANGING  c_data_to_be_filled    TYPE any,
      fill_structure IMPORTING i_current_data_element TYPE REF TO zif_yy_data_element
                     CHANGING  c_structured_data      TYPE any,
      fill_table     IMPORTING i_current_data_element TYPE REF TO zif_yy_data_element
                     CHANGING  c_table_data           TYPE ANY TABLE,
      camel_to_underscore IMPORTING i_original_name           TYPE string
                          RETURNING VALUE(r_underscored_name) TYPE string.
ENDCLASS.



CLASS zcl_jak_data_in IMPLEMENTATION.


  METHOD camel_to_underscore.

    DATA: my_offset TYPE i.

    my_offset = find( val = i_original_name regex = '[a-z0-9][A-Z]' ).

    IF my_offset > -1.
      r_underscored_name = camel_to_underscore( i_original_name = substring( val = i_original_name off = 0 len = my_offset + 1 ) && '_' && substring( val = i_original_name off = my_offset + 1 ) ).
    ELSE.
      r_underscored_name = i_original_name.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.

    super->constructor( i_current_status = i_current_status ).
    me->raw_text = i_raw_text.

    IF me->current_status-is_valid = abap_true.
      TRY.
          me->data_service = zcl_yy_data_service=>create_instance_with_json( i_json = me->raw_text ).
        CATCH zcx_yy_unsupported_data INTO DATA(invalid_data_error).
          me->invalidate_status( i_status_message = |JSON data is invalid. Error message was: { invalid_data_error->get_longtext( ) }| ).
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD fill_structure.

    DATA: data_value TYPE zif_yy_data_element=>ty_structure.
    FIELD-SYMBOLS: <value_element> TYPE any.

    i_current_data_element->get_value( IMPORTING e_value = data_value ).
    LOOP AT data_value INTO DATA(data_value_element).
      UNASSIGN: <value_element>.
      DATA(value_name) = data_value_element-element->get_descriptor( )->get_name( ).
      ASSIGN COMPONENT value_name OF STRUCTURE c_structured_data TO <value_element>.
      IF <value_element> IS NOT ASSIGNED.
        " Let's try some camel case conversion assignment
        ASSIGN COMPONENT camel_to_underscore( i_original_name = value_name ) OF STRUCTURE c_structured_data TO <value_element>.
      ENDIF.
      IF <value_element> IS ASSIGNED.
        fill_with_data_element( EXPORTING i_current_data_element = data_value_element-element
                                CHANGING  c_data_to_be_filled    = <value_element> ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD fill_table.

    DATA: table_value TYPE zif_yy_data_element=>ty_table,
          table_line  TYPE zif_yy_data_element=>ty_table_element,
          line_index  TYPE i.

    FIELD-SYMBOLS: <table_line> TYPE any.

    i_current_data_element->get_value( IMPORTING e_value = table_value ).
    WHILE line_index < lines( table_value ).
      INSERT INITIAL LINE INTO TABLE c_table_data ASSIGNING <table_line>.
      ADD 1 TO line_index.
      READ TABLE table_value INTO table_line WITH TABLE KEY index = line_index.
      fill_with_data_element( EXPORTING i_current_data_element = table_line-element
                              CHANGING  c_data_to_be_filled    = <table_line> ).
    ENDWHILE.


  ENDMETHOD.


  METHOD fill_with_data_element.
    CASE i_current_data_element->get_descriptor( )->get_type( )->get_type_name( ).
      WHEN zif_yy_data_element_type=>structure.
        fill_structure( EXPORTING i_current_data_element = i_current_data_element
                        CHANGING  c_structured_data      = c_data_to_be_filled ).
      WHEN zif_yy_data_element_type=>table.
        fill_table( EXPORTING i_current_data_element = i_current_data_element
                    CHANGING  c_table_data           = c_data_to_be_filled ).
      WHEN zif_yy_data_element_type=>number.
        i_current_data_element->get_value( IMPORTING e_value = c_data_to_be_filled ).
      WHEN zif_yy_data_element_type=>string.
        i_current_data_element->get_value( IMPORTING e_value = c_data_to_be_filled ).
      WHEN OTHERS.
        CLEAR: c_data_to_be_filled.
    ENDCASE.
  ENDMETHOD.


  METHOD handle_http_request.

    CLEAR: e_raw_text, e_status.

    IF i_http_request->get_header_field( i_name = if_web_http_header=>content_type ) <> if_web_http_header=>accept_application_json.
      e_status-is_valid = abap_false.
      e_status-message = 'HTTP request doesn''t contain JSON!'.
      RETURN.
    ENDIF.
    TRY.
        e_raw_text = i_http_request->get_text( ).
      CATCH cx_web_message_error INTO DATA(web_message_error).
        e_status-is_valid = abap_false.
        e_status-message = |Unable to retrieve content of HTTP request. Error was: { web_message_error->get_longtext( ) }|.
        RETURN.
    ENDTRY.

    e_status-is_valid = abap_true.

  ENDMETHOD.


  METHOD initialize_with_http_request.
    handle_http_request( EXPORTING i_http_request = i_http_request
                         IMPORTING e_raw_text     = DATA(raw_text)
                                   e_status       = DATA(status) ).
    r_jak_data = NEW zcl_jak_data_in( i_raw_text       = raw_text
                                      i_current_status = status ).
  ENDMETHOD.


  METHOD initialize_with_json.
    DATA status TYPE zif_jak_data=>ty_s_jak_status.
    status-is_valid = abap_true.
    r_jak_data = NEW zcl_jak_data_in( i_raw_text       = i_json
                                      i_current_status = status ).
  ENDMETHOD.


  METHOD zif_jak_data_in~fill.

    fill_with_data_element( EXPORTING i_current_data_element = me->data_service->get_element( )
                            CHANGING  c_data_to_be_filled    = c_my_data ).

  ENDMETHOD.
ENDCLASS.

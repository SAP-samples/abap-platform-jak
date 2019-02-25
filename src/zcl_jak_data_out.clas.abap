CLASS zcl_jak_data_out DEFINITION
  PUBLIC
  INHERITING FROM zcl_jak_data
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES: zif_jak_data_out.
    CLASS-METHODS: initialize IMPORTING i_my_data         TYPE any
                              RETURNING VALUE(r_jak_data) TYPE REF TO zif_jak_data_out.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS: constructor IMPORTING i_data           TYPE any
                                   i_current_status TYPE zif_jak_data=>ty_s_jak_status.
ENDCLASS.



CLASS ZCL_JAK_DATA_OUT IMPLEMENTATION.


  METHOD constructor.

    super->constructor( i_current_status = i_current_status ).

    DATA(json_writer) = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).
    CALL TRANSFORMATION id SOURCE yy = i_data RESULT XML json_writer.
    raw_text = cl_abap_conv_codepage=>create_in( )->convert( source = json_writer->get_output( ) ).
    raw_text = shift_left( val = raw_text places = 6 ).
    raw_text = shift_right( val = raw_text places = 1 ).

  ENDMETHOD.


  METHOD initialize.
    DATA status TYPE zif_jak_data=>ty_s_jak_status.
    status-is_valid = abap_true.
    r_jak_data = NEW zcl_jak_data_out( i_data           = i_my_data
                                       i_current_status = status ).
  ENDMETHOD.


  METHOD zif_jak_data_out~get_json.
    r_json = raw_text.
  ENDMETHOD.


  METHOD zif_jak_data_out~prepare_http_response.
    i_http_response->set_header_field( i_name = if_web_http_header=>content_type i_value = if_web_http_header=>accept_application_json ).
    i_http_response->set_text( i_text = raw_text ).
  ENDMETHOD.
ENDCLASS.

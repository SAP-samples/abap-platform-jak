*"* use this source file for your ABAP unit test classes
CLASS ltcl_jak_data_out DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS:
      smoke_test_http FOR TESTING RAISING cx_static_check,
      smoke_test_json FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_jak_data_out IMPLEMENTATION.

  METHOD smoke_test_http.

    TYPES: BEGIN OF ty_s_rumpelkatze,
             rumpel TYPE string,
           END OF ty_s_rumpelkatze,
           ty_t_rumpelkatze TYPE TABLE OF ty_s_rumpelkatze.

    DATA: http_response_spy TYPE REF TO if_web_http_response,
          my_data           TYPE ty_t_rumpelkatze,
          jak_data_out      TYPE REF TO zif_jak_data_out.

    my_data = VALUE #( ( rumpel = 'katze' )
                       ( rumpel = 'kater' ) ).
    jak_data_out = zcl_jak_data_out=>initialize( i_my_data = my_data ).

    http_response_spy ?= cl_abap_testdouble=>create( 'if_web_http_response' ).
    cl_abap_testdouble=>configure_call( double = http_response_spy )->and_expect( )->is_called_once( ).
    http_response_spy->set_header_field( i_name = if_web_http_header=>content_type i_value = if_web_http_header=>accept_application_json ).

    cl_abap_testdouble=>configure_call( double = http_response_spy )->and_expect( )->is_called_once( ).
    http_response_spy->set_text( i_text = '[{"RUMPEL":"katze"},{"RUMPEL":"kater"}]' ).

    jak_data_out->prepare_http_response( i_http_response = http_response_spy ).

    cl_abap_testdouble=>verify_expectations( double = http_response_spy ).

  ENDMETHOD.

  METHOD smoke_test_json.

    TYPES: BEGIN OF numbers,
             one   TYPE string,
             two   TYPE string,
             three TYPE string,
             four  TYPE string,
           END OF numbers.
    DATA: my_data      TYPE numbers,
          jak_data_out TYPE REF TO zif_jak_data_out.

    my_data = VALUE #( one = 'eins' three = 'drei' ).
    jak_data_out = zcl_jak_data_out=>initialize( i_my_data = my_data ).

    cl_abap_unit_assert=>assert_equals( exp = '{"ONE":"eins","TWO":"","THREE":"drei","FOUR":""}' act = jak_data_out->get_json( ) ).

  ENDMETHOD.

ENDCLASS.

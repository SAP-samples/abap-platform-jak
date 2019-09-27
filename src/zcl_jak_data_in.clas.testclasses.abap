*"* use this source file for your ABAP unit test classes
CLASS ltcl_jak_data_in DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS:
      smoke_test_http             FOR TESTING RAISING cx_static_check,
      smoke_test_json             FOR TESTING RAISING cx_static_check,
      camel_underscore_conversion FOR TESTING RAISING cx_static_check,
      issue_2                     FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_jak_data_in IMPLEMENTATION.

  METHOD smoke_test_http.

    TYPES: BEGIN OF ty_s_rumpelkatze,
             rumpel TYPE string,
           END OF ty_s_rumpelkatze,
           ty_t_rumpelkatze TYPE TABLE OF ty_s_rumpelkatze.

    DATA: http_request_mock TYPE REF TO if_web_http_request,
          my_data           TYPE ty_t_rumpelkatze,
          expected_data     TYPE ty_t_rumpelkatze.

    http_request_mock ?= cl_abap_testdouble=>create( 'if_web_http_request' ).
    cl_abap_testdouble=>configure_call( double = http_request_mock )->returning( value = if_web_http_header=>accept_application_json ).
    http_request_mock->get_header_field( i_name = if_web_http_header=>content_type ).
    cl_abap_testdouble=>configure_call( double = http_request_mock )->returning( value = |[ \{ "rumpel" : "katze" \}, \{ "rumpel" : "kater" \} ]| ).
    http_request_mock->get_text( ).

    DATA(jak_data) = zcl_jak_data_in=>initialize_with_http_request( i_http_request = http_request_mock ).
    cl_abap_unit_assert=>assert_true( jak_data->get_status( )-is_valid ).
    jak_data->fill( CHANGING c_my_data = my_data ).
    expected_data = VALUE #( ( rumpel = 'katze' )
                             ( rumpel = 'kater' ) ).
    cl_abap_unit_assert=>assert_equals( exp = expected_data act = my_data ).
  ENDMETHOD.

  METHOD smoke_test_json.

    TYPES: BEGIN OF numbers,
             one   TYPE string,
             two   TYPE string,
             three TYPE string,
             four  TYPE string,
           END OF numbers,
           numbers_table TYPE TABLE OF numbers.
    DATA: my_data       TYPE numbers_table,
          expected_data TYPE numbers_table.

    DATA(jak_data) = zcl_jak_data_in=>initialize_with_json( i_json = '[ { "one" : "eins", "three": "drei" }, { "one" : "uno", "two": "dos" } , { "three" : "tre", "four": "fire" } ]' ).
    cl_abap_unit_assert=>assert_true( jak_data->get_status( )-is_valid ).
    jak_data->fill( CHANGING c_my_data = my_data ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( my_data ) ).
    expected_data = VALUE #( ( one = 'eins' three = 'drei' )
                             ( one = 'uno' two = 'dos' )
                             ( three = 'tre' four = 'fire' ) ).
    cl_abap_unit_assert=>assert_equals( exp = expected_data act = my_data ).

  ENDMETHOD.

  METHOD camel_underscore_conversion.
    TYPES: BEGIN OF strange_structure,
             rumpel_katze     TYPE string,
             nettes_haus_tier TYPE string,
           END OF strange_structure,
           strange_table TYPE TABLE OF strange_structure.
    DATA: my_data       TYPE strange_table,
          expected_data TYPE strange_table.

    DATA(jak_data) = zcl_jak_data_in=>initialize_with_json( i_json = '[ { "rumpelKatze" : "Felix", "nettesHausTier": "Klar Doch!" }, { "rumpelKatze" : "Hugo", "nettesHausTier": "Eher nicht!" } ]' ).
    cl_abap_unit_assert=>assert_true( jak_data->get_status( )-is_valid ).
    jak_data->fill( CHANGING c_my_data = my_data ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( my_data ) ).
    expected_data = VALUE #( ( rumpel_katze = 'Felix' nettes_haus_tier = 'Klar Doch!' )
                             ( rumpel_katze = 'Hugo' nettes_haus_tier = 'Eher nicht!' ) ).
    cl_abap_unit_assert=>assert_equals( exp = expected_data act = my_data ).
  ENDMETHOD.

  METHOD issue_2.

    TYPES: BEGIN OF ty_addr,
             bnm  TYPE string,
             pncd TYPE string,
           END OF ty_addr,
           BEGIN OF Ty_adadr,
             addr TYPE ty_addr,
             ntr  TYPE STANDARD TABLE OF string WITH NON-UNIQUE DEFAULT KEY,
           END OF ty_adadr,
           BEGIN OF ty_something,
             stj_cd TYPE string,
             lgnm   TYPE string,
             nba    TYPE STANDARD TABLE OF string WITH NON-UNIQUE DEFAULT KEY,
             adadr  TYPE STANDARD TABLE OF ty_adadr WITH NON-UNIQUE DEFAULT KEY,
             pradr  TYPE ty_adadr,
           END OF ty_something.

    DATA: my_data       TYPE ty_something,
          expected_data TYPE ty_something.

    DATA(source_json) = |\{"stjCd":"AP003","lgnm":"MS CORPORATION","nba":["Bonded Warehouse","EOU / STP / EHTP","Factory / Manufacturing","Input Service Distributor (ISD)","Leasing | &&
                        |Business"],"adadr":[\{"addr":\{"bnm":"ELPHINSTONE BUILDING","pncd":"400001"\},"ntr":["Wholesale Business"]\}],"pradr":\{"addr":\{"bnm":"KATGARA HOUSE","pncd":"400006"\}| &&
                        |,"ntr":["Wholesale Business"]\}\}|.

    DATA(jak_data) = zcl_jak_data_in=>initialize_with_json( i_json = source_json ).
    cl_abap_unit_assert=>assert_true( jak_data->get_status( )-is_valid ).
    jak_data->fill( CHANGING c_my_data = my_data ).

    expected_data = VALUE #( stj_cd = 'AP003'
                             lgnm = 'MS CORPORATION'
                             nba = VALUE #( ( `Bonded Warehouse` ) ( `EOU / STP / EHTP` ) ( `Factory / Manufacturing` ) ( `Input Service Distributor (ISD)` ) ( `Leasing Business` ) )
                             adadr = VALUE #( ( addr = VALUE #( bnm = `ELPHINSTONE BUILDING` pncd = `400001` ) ntr = VALUE #( ( `Wholesale Business` ) ) ) )
                             pradr = VALUE #( addr = VALUE #( bnm = `KATGARA HOUSE` pncd = `400006` ) ntr = VALUE #( ( `Wholesale Business` ) ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = expected_data act = my_data ).

  ENDMETHOD.

ENDCLASS.

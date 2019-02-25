INTERFACE zif_jak_data_out PUBLIC.
  INTERFACES: zif_jak_data.
  ALIASES: get_status FOR zif_jak_data~get_status.

  METHODS:
    get_json              RETURNING VALUE(r_json)   TYPE string,
    prepare_http_response IMPORTING i_http_response TYPE REF TO if_web_http_response.
ENDINTERFACE.

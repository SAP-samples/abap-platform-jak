INTERFACE zif_jak_data PUBLIC.

  TYPES: BEGIN OF ty_s_jak_status,
           is_valid TYPE abap_boolean,
           message  TYPE string,
         END OF ty_s_jak_status.

  METHODS: get_status RETURNING VALUE(r_status) TYPE ty_s_jak_status.

ENDINTERFACE.

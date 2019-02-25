INTERFACE zif_jak_data_in PUBLIC.
  INTERFACES: zif_jak_data.
  ALIASES: get_status FOR zif_jak_data~get_status.

  METHODS: fill CHANGING c_my_data TYPE any.
ENDINTERFACE.

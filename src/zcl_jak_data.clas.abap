CLASS zcl_jak_data DEFINITION ABSTRACT
  PUBLIC
  CREATE PROTECTED.

  PUBLIC SECTION.
    INTERFACES: zif_jak_data.
  PROTECTED SECTION.
    DATA: current_status TYPE zif_jak_data=>ty_s_jak_status,
          raw_text TYPE string.
    METHODS:
      constructor IMPORTING i_current_status TYPE zif_jak_data=>ty_s_jak_status,
      invalidate_status IMPORTING i_status_message TYPE string,
      validate_status IMPORTING i_status_message TYPE string OPTIONAL.
ENDCLASS.



CLASS ZCL_JAK_DATA IMPLEMENTATION.


  METHOD constructor.
    me->current_status = i_current_status.
  ENDMETHOD.


  METHOD invalidate_status.
    me->current_status-is_valid = abap_false.
    me->current_status-message = i_status_message.
  ENDMETHOD.


  METHOD validate_status.
    me->current_status-is_valid = abap_true.
    me->current_status-message = i_status_message.
  ENDMETHOD.


  METHOD zif_jak_data~get_status.
    r_status = current_status.
  ENDMETHOD.
ENDCLASS.

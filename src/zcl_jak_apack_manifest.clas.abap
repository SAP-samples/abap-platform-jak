CLASS zcl_jak_apack_manifest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_apack_manifest,
    if_badi_interface.
    METHODS: constructor.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_jak_apack_manifest IMPLEMENTATION.
  METHOD constructor.
    if_apack_manifest~descriptor-group_id = 'sap.com'.
    if_apack_manifest~descriptor-artifact_id = 'jak'.
    if_apack_manifest~descriptor-version = '0.1'.
    if_apack_manifest~descriptor-git_url = 'https://github.com/SebastianWolf-SAP/jak.git'.
    if_apack_manifest~descriptor-dependencies = VALUE #( ( group_id    = 'sap.com'
                                                           artifact_id = 'yy'
                                                           git_url     = 'https://github.com/SebastianWolf-SAP/yy.git' ) ).
  ENDMETHOD.

ENDCLASS.

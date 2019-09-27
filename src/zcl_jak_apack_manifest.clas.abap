CLASS zcl_jak_apack_manifest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_apack_manifest.
    METHODS: constructor.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_jak_apack_manifest IMPLEMENTATION.
  METHOD constructor.
    if_apack_manifest~descriptor-group_id = 'sap.com'.
    if_apack_manifest~descriptor-artifact_id = 'abap-platform-jak'.
    if_apack_manifest~descriptor-version = '0.2'.
    if_apack_manifest~descriptor-git_url = 'https://github.com/SAP/abap-platform-jak.git'.
    if_apack_manifest~descriptor-dependencies = VALUE #( ( group_id    = 'sap.com'
                                                           artifact_id = 'abap-platform-yy'
                                                           git_url     = 'https://github.com/SAP/abap-platform-yy.git' ) ).
  ENDMETHOD.

ENDCLASS.

# JAK 

<hr />

**Attention: This is sample code!** 

This repository contains sample code which should not be used in production. It only shows the capabilities of [APACK - the ABAP package and dependency manager](https://blogs.sap.com/2019/05/06/introducing-apack-a-package-and-dependency-manager-for-abap/).

<hr />

**The JSON ABAP Konverter**

The JSON ABAP Konverter (JAK) is an alternative way of handling JSON on an ABAP system running on the SAP Cloud Platform. Keep in mind that this is just a demo. In production, you better use the officially supported libraries...

Just hand your JSON raw data as string or encapsulated in an HTTP request to the JAK library and it will automatically transfer the JSON data to a compatible ABAP structure or internal table - and vice versa. No need to develop anything on your own - JAK will do the magic for you. Data structure matching is done based on the names of the table/structure rows and the JSON identifiers. The ABAP data field can contain more or less fields than the JSON which is used, JAK will automatically only copy the matching fields and silently ignore the rest.

## Prerequisites
Please make sure to fulfill the following requirements:
* You have access to an SAP Cloud Platform ABAP Environment instance (see [here](https://blogs.sap.com/2018/09/04/sap-cloud-platform-abap-environment) for additional information)
* You have downloaded and installed [ABAP Development Tools for SAP NetWeaver](https://tools.hana.ondemand.com/#abap) (ADT)
* You have created an ABAP Cloud Project in ADT that allows you to access your SAP Cloud Platform ABAP Environment instance
* You have installed the [abapGit](https://github.com/abapGit/eclipse.abapgit.org) plug-in for Eclipse [via the updatesite](https://eclipse.abapgit.org/updatesite/)
* You have installed the [YY Data Service](https://github.com/SAP/abap-platform-yy) or run an ABAP instance which supports the APACK package and dependency manager. This will import the YY Data Service automatically when you import this project.

## Download and Installation
Use the abapGit plug-in to install the JSON ABAP Konverter by executing the following steps:
* In ADT create the package `/DMO/JAK` as a subpackage under `/DMO/SAP` (keep the defaulted values)
* In ADT click on `Window` > `Show View` > `Other...` and choose the entry `abapGit Repositories` to open the abapGit view
* Make sure to have the correct ABAP Cloud Project selected (See the little headline in the abapGit view for the current project)
* Click on the `+` icon to clone an abapGit repository
* Provide the URL of this repository: `https://github.com/SAP/abap-platform-jak.git`
* On the next page choose the master branch and provide the package `/DMO/JAK`
* Provide a valid transport request and choose `Finish`. This starts the cloning of the repository - which might take a few minutes
* Once the cloning has finished, refresh your project tree
* Usually, the imported objects are not activated after cloning. Use the mass activation feature in ADT to activate those artifacts.

## Usage
### Incoming data
You already have a JSON with data or you get it via an HTTP reqest and would like to transfer it to a compatible ABAP data field? Nothing easier than that: Just get an instance of `ZCL_JAK_DATA_IN` by calling the corresponding static method - either `INITIALIZE_WITH_HTTP_REQUEST` or `INITIALIZE_WITH_JSON`. Your ABAP data field can then simply be filled by calling the method `ZIF_JAK_DATA_IN~FILL`.

### Outgoing data
You have an ABAP data field ready to send out to the world as JSON - either directly the text or in an HTTP response? If you want to get it converted automatically, simply initialze `ZCL_JAK_DATA_OUT` by calling the `INITIALIZE` method and pass your field to it. The methods `ZIF_JAK_DATA_OUT~GET_JSON` and `ZIF_JAK_DATA_OUT~PREPARE_HTTP_RESPONSE` will do the job for you.

## Known Issues
As mentioned before, after cloning a abapGit repository some objects might not be active. Use the mass activation feature in ADT to activate those artifacts.  

## License
Copyright (c) 2019-2020 SAP SE or an SAP affiliate company.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use any file of this project except in compliance with the License.

You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the LICENSE for the specific language governing permissions and limitations under the License.

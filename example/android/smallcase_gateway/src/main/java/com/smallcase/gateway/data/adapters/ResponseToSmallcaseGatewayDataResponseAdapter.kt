// package com.smallcase.gateway.data.adapters
//
// import com.smallcase.gateway.data.models.*
// import com.squareup.moshi.*
// import com.squareup.moshi.JsonQualifier
// import okio.Buffer
//
// /**
// *Parser for the SMT response into string as required to pass back to the consumer
// *DataString is used insdie the Mapped Object
// **/
// class ResponseToSmallcaseGatewayDataResponseAdapter {
//
//    @ToJson
//    fun toJson(writer: JsonWriter, @DataString string: String) {
//        writer.value(Buffer().writeUtf8(string))
//    }
//
//    @FromJson
//    @DataString
//    fun fromJson(reader: JsonReader, delegate: JsonAdapter<Object>): String {
//
//        // Now the intermediate gateway_loader object (a Map) comes here
//        val data: Object = reader.readJsonValue() as Object
//        // Just delegate to JsonAdapter<Object>, so we got a JSON string of the object
//        return delegate.toJson(data)
//    }
//
//    @Retention(AnnotationRetention.RUNTIME)
//    @JsonQualifier
//    annotation class DataString
// }

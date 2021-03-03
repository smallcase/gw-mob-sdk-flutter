package com.example.scgateway_flutter_plugin.models

import com.google.gson.annotations.SerializedName

data class AllSmallcasesDTO(

        @SerializedName("smallcases")
        val smallcases: List<SmallcasesDTO>? = null
)

package io.wks.terraform.orderservice.delivery

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonValue

data class CountryCode private constructor(private val value: com.neovisionaries.i18n.CountryCode) {
    companion object {
        @JvmStatic
        @JsonCreator
        fun of(value: String) = CountryCode(com.neovisionaries.i18n.CountryCode.getByCode(value, false))
    }

    @JsonValue
    override fun toString(): String = value.alpha2
}
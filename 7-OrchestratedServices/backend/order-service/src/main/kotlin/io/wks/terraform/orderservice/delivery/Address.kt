package io.wks.terraform.orderservice.delivery

import com.fasterxml.jackson.annotation.JsonProperty

data class Address(
    @JsonProperty("countryCode")
    val countryCode: CountryCode,
)

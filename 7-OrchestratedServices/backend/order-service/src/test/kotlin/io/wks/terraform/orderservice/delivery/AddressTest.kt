package io.wks.terraform.orderservice.delivery

import com.fasterxml.jackson.databind.ObjectMapper
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

class AddressTest {

    val objectMapper = ObjectMapper()
        .findAndRegisterModules()

    @Test
    fun testDeserialization(){

        val json = """{"countryCode": "TR"}"""

        val address = objectMapper.readValue(json, Address::class.java)

        assertEquals(CountryCode.of("TR"), address.countryCode)
    }
}
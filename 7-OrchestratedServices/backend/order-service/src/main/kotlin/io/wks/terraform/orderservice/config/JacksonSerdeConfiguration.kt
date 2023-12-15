package io.wks.terraform.orderservice.config

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.databind.SerializerProvider
import com.fasterxml.jackson.databind.module.SimpleModule
import com.fasterxml.jackson.databind.ser.std.StdSerializer
import org.javamoney.moneta.function.MonetaryQueries
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import javax.money.MonetaryAmount


@Configuration
class JacksonSerdeConfiguration {
    @Bean
    fun customSerdeModule(): SimpleModule {
        return with(SimpleModule()) {
            addSerializer(MonetaryAmount::class.java, MonetaryAmountSerializer)
        }
    }
}

object MonetaryAmountSerializer : StdSerializer<MonetaryAmount>(MonetaryAmount::class.java) {
    override fun serialize(amount: MonetaryAmount?, gen: JsonGenerator, ctx: SerializerProvider?) {
        when (amount) {
            null -> gen.writeNull()
            else -> with(gen) {
                writeStartObject()
                writeStringField("currency", amount.currency.currencyCode)
                writeNumberField("amountMinorUnits", amount.query(MonetaryQueries.convertMinorPart()))
                writeEndObject()
            }
        }
    }

}
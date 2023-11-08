package io.wks.terraform.shippingprice

import java.math.BigDecimal
import javax.money.MonetaryAmount

@JvmInline
value class CountryCode private constructor(private val value: com.neovisionaries.i18n.CountryCode) {
    companion object {
        fun of(value: String) = CountryCode(com.neovisionaries.i18n.CountryCode.getByCode(value, false))
    }

    override fun toString(): String = value.alpha2
}

@JvmInline
value class CurrencyCode private constructor(private val value: com.neovisionaries.i18n.CurrencyCode) {
    companion object {
        fun of(value: String) = CurrencyCode(com.neovisionaries.i18n.CurrencyCode.valueOf(value))
    }

    override fun toString() = value.toString()
}

@JvmInline
value class Kilometer(val value: BigDecimal)

@JvmInline
value class Kilogram(val value: BigDecimal)

data class RateCard(
    val source: CountryCode,
    val destination: CountryCode,
    val distance: Kilometer,
    val ratePerKgPerKm: MonetaryAmount,
    val urgencyMultiplier: BigDecimal,
) {
    fun calculatePrice(
        weight: Kilogram,
        isUrgent: Boolean
    ): MonetaryAmount {
        return ratePerKgPerKm
            .multiply(weight.value)
            .multiply(distance.value)
            .multiply(
                if (isUrgent) {
                    urgencyMultiplier
                } else {
                    BigDecimal.ONE
                }
            )
    }
}
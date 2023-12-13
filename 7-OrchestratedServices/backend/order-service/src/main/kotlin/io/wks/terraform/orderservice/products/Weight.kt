package io.wks.terraform.orderservice.products

import java.math.BigDecimal

@JvmInline
value class Kilogram(val value: BigDecimal) {
    operator fun times(other: Kilogram) = Kilogram(value.multiply(other.value))
    operator fun plus(other: Kilogram) = Kilogram(value.add(other.value))
    operator fun times(units: Int) = Kilogram(value.multiply(units.toBigDecimal()))

}
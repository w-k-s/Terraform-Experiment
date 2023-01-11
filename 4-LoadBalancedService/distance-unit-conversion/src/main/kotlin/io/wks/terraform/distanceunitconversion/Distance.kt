package io.wks.terraform.distanceunitconversion

import java.lang.IllegalArgumentException
import java.math.BigDecimal
import java.math.RoundingMode

enum class Distance(val unit: String, val meterMultiplier: BigDecimal) {
    KILOMETERS("km", BigDecimal(1000)),
    METERS("m", BigDecimal(1)),
    CENTIMETERS("cm", BigDecimal(0.01)),
    MILLIMETERS("mm", BigDecimal(0.001));

    companion object {
        fun convert(value: BigDecimal, from: Distance, to: Distance): BigDecimal {
            return value.multiply(from.meterMultiplier)
                .divide(to.meterMultiplier, value.precision(), RoundingMode.HALF_UP)
        }

        fun unitOf(unit: String): Distance {
            return Distance.values()
                .firstOrNull { it.unit.equals(unit, ignoreCase = true) }
                ?: throw IllegalArgumentException("Unsupported or unknown unit: '$unit'")
        }
    }
}

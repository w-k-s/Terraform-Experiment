package io.wks.terraform.distanceunitconversion

import org.springframework.http.HttpStatusCode
import org.springframework.http.ProblemDetail
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.math.BigDecimal

data class ConversionResponse(
    val fromValue: BigDecimal,
    val fromUnit: String,
    val toUnit: String,
    val result: BigDecimal
)

@RestController
@RequestMapping("/api/v1/convert/distance")
class DistanceUnitConversionController {

    @GetMapping(
        "/{value}/{from}/to/{to}"
    )
    fun convert(
        @PathVariable("value") from: BigDecimal,
        @PathVariable("from") fromUnit: String,
        @PathVariable("to") toUnit: String
    ): ConversionResponse {
        val result = Distance.convert(
            from,
            Distance.unitOf(fromUnit),
            Distance.unitOf(toUnit)
        )
        return ConversionResponse(
            fromValue = from,
            fromUnit = fromUnit,
            toUnit = toUnit,
            result = result
        )
    }

    @ExceptionHandler(Exception::class)
    fun onException(exception: Exception): ProblemDetail {
        return ProblemDetail.forStatusAndDetail(HttpStatusCode.valueOf(500), exception.message ?: "Irrecoverable error")
    }
}
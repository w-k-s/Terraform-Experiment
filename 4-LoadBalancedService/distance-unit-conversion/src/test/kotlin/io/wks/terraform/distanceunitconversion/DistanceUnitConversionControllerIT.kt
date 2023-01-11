package io.wks.terraform.distanceunitconversion

import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.Arguments
import org.junit.jupiter.params.provider.MethodSource
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get
import java.math.BigDecimal
import java.util.stream.Stream

@AutoConfigureMockMvc
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class DistanceUnitConversionControllerIT {

    companion object {
        @JvmStatic
        fun provideTestData(): Stream<Arguments> = Stream.of(
            Arguments.of(BigDecimal("50"), "km", "km", BigDecimal("50")),
            Arguments.of(BigDecimal("50"), "km", "m", BigDecimal("50000")),
            Arguments.of(BigDecimal("50"), "km", "cm", BigDecimal("5000000")),
            Arguments.of(BigDecimal("50"), "km", "mm", BigDecimal("50000000")),

            Arguments.of(BigDecimal("50"), "m", "km", BigDecimal("0.05")),
            Arguments.of(BigDecimal("50"), "m", "m", BigDecimal("50")),//?
            Arguments.of(BigDecimal("50"), "m", "cm", BigDecimal("5000")),
            Arguments.of(BigDecimal("50"), "m", "mm", BigDecimal("50000")),

            Arguments.of(BigDecimal("50"), "cm", "km", BigDecimal("0.00")),
            Arguments.of(BigDecimal("50"), "cm", "m", BigDecimal("0.50")),
            Arguments.of(BigDecimal("50"), "cm", "cm", BigDecimal("50")),
            Arguments.of(BigDecimal("50"), "cm", "mm", BigDecimal("500")),

            Arguments.of(BigDecimal("50"), "mm", "km", BigDecimal("0")),
            Arguments.of(BigDecimal("50"), "mm", "m", BigDecimal("0.05")),
            Arguments.of(BigDecimal("50"), "mm", "cm", BigDecimal("5")),
            Arguments.of(BigDecimal("50"), "mm", "mm", BigDecimal("50")),
        )
    }

    @Autowired
    private lateinit var mockMvc: MockMvc

    @ParameterizedTest
    @MethodSource("provideTestData")
    fun `GIVEN a value and unit WHEN converting THEN result is correct`(
        from: BigDecimal,
        fromUnit: String,
        toUnit: String,
        expected: BigDecimal
    ) {
        mockMvc.get("/api/v1/convert/distance/$from/$fromUnit/to/$toUnit")
            .andExpect {
                status { isOk() }
                content {
                    json(
                        """{
                      "fromValue": $from,
                        "fromUnit": "$fromUnit",
                        "toUnit": "$toUnit",
                        "result": $expected
                    }""".trimMargin()
                    )
                }
            }
    }

    @Test
    fun `GIVEN a value and invalid unit WHEN converting THEN error`() {
        mockMvc.get("/api/v1/convert/distance/50/km/to/lightyears")
            .andExpect {
                status { isInternalServerError() }
                content {
                    json(
                        """{
                            "type": "about:blank",
                            "title": "Internal Server Error",
                            "status": 500,
                            "detail": "Unsupported or unknown unit: 'lightyears'",
                            "instance": "/api/v1/convert/distance/50/km/to/lightyears"
                        }""".trimMargin()
                    )
                }
            }
    }
}
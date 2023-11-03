package io.wks.terraform.shippingprice

import io.wks.mavenflyway.jooq.shipping_price.Tables
import io.wks.mavenflyway.jooq.shipping_price.tables.RouteRateCard.ROUTE_RATE_CARD
import org.jooq.DSLContext
import org.springframework.stereotype.Repository

@Repository
class RateCardDao(private val dslContext: DSLContext) {

    fun findByCountry(
        source: CountryCode,
        destination: CountryCode
    ): RateCard? {
        return dslContext.selectFrom(Tables.ROUTE_RATE_CARD)
            .where(ROUTE_RATE_CARD.SOURCE_COUNTRY.eq(source.toString()))
            .and(ROUTE_RATE_CARD.DESTINATION_COUNTRY.eq(destination.toString()))
            .fetchOne {
                RateCard(
                    source = CountryCode.of(it.sourceCountry),
                    destination = CountryCode.of(it.destinationCountry),
                    distance = Kilometer(it.distanceKm.toBigDecimal()),
                    ratePerKgPerKm = it.ratePerKgPerKm.toBigDecimal(),
                    urgencyMultiplier = it.urgencyMultiplier.toBigDecimal(),
                    currency = CurrencyCode.of(it.currency)
                )
            }
    }
}
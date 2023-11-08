package io.wks.terraform.shippingprice

import io.grpc.stub.StreamObserver
import io.wks.terraform.shippingprice.BusinessRuleViolationException.Companion.UnsupportedDestination
import io.wks.terraform.shippingpriceapi.ShippingPriceRequest
import io.wks.terraform.shippingpriceapi.ShippingPriceResponse
import io.wks.terraform.shippingpriceapi.ShippingPriceServiceGrpc
import net.devh.boot.grpc.server.service.GrpcService
import org.javamoney.moneta.function.MonetaryQueries

@GrpcService
class ShippingPriceService(private val rateCardDao: RateCardDao) :
    ShippingPriceServiceGrpc.ShippingPriceServiceImplBase() {

    override fun price(
        request: ShippingPriceRequest,
        responseObserver: StreamObserver<ShippingPriceResponse>?
    ) {
        val rate = rateCardDao.findByCountry(
            source = CountryCode.of(request.sourceCountry),
            destination = CountryCode.of(request.destinationCountry),
        )?.calculatePrice(Kilogram(request.weightKg.toBigDecimal()), request.urgent)

        when (rate) {
            null -> responseObserver?.onError(
                BusinessRuleViolationException(
                    rule = UnsupportedDestination(
                        sourceCountry = request.sourceCountry,
                        destinationCountry = request.destinationCountry
                    )
                )
            )

            else -> responseObserver?.let {
                it.onNext(
                    ShippingPriceResponse.newBuilder()
                        .setCurrency(rate.currency.currencyCode)
                        .setPriceMinorUnits(rate.query(MonetaryQueries.convertMinorPart()))
                        .build()
                )
                it.onCompleted()
            }
        }
    }
}
package io.wks.terraform.shippingprice

import io.grpc.stub.StreamObserver
import io.wks.terraform.shippingpriceapi.ShippingPriceRequest
import io.wks.terraform.shippingpriceapi.ShippingPriceResponse
import io.wks.terraform.shippingpriceapi.ShippingPriceServiceGrpc
import net.devh.boot.grpc.server.service.GrpcService

@GrpcService
class ShippingPriceService(private val rateCardDao: RateCardDao) :
    ShippingPriceServiceGrpc.ShippingPriceServiceImplBase() {

    override fun price(
        request: ShippingPriceRequest,
        responseObserver: StreamObserver<ShippingPriceResponse>?
    ) {
        super.price(request, responseObserver)

        val rate = rateCardDao.findByCountry(
            source = CountryCode.of(request.sourceCountry),
            destination = CountryCode.of(request.destinationCountry),
        )?.calculatePrice(Kilogram(request.weightKg.toBigDecimal()), request.urgent)

        when (rate) {
            null -> responseObserver?.onError(Throwable("Packages can not be delivered from '${request.sourceCountry}' to '${request.destinationCountry}'"))
            else -> responseObserver?.let {
                it.onNext(ShippingPriceResponse.newBuilder().build())
                it.onCompleted()
            }
        }
    }
}
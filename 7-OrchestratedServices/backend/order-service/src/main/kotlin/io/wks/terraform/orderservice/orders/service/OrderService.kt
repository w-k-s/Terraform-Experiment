package io.wks.terraform.orderservice.orders.service

import io.wks.terraform.orderservice.orders.Order
import io.wks.terraform.shippingpriceapi.ShippingPriceRequest
import io.wks.terraform.shippingpriceapi.ShippingPriceServiceGrpc
import net.devh.boot.grpc.client.inject.GrpcClient
import org.javamoney.moneta.FastMoney
import org.springframework.stereotype.Service
import javax.money.Monetary

@Service
class OrderService(
    @GrpcClient("shippingPriceService")
    private val shippingPriceStub: ShippingPriceServiceGrpc.ShippingPriceServiceBlockingStub
) {

    fun createOrder(request: OrderRequest): OrderResponse {
        val price = shippingPriceStub.price(
            ShippingPriceRequest.newBuilder()
                .setWeightKg(request.totalWeight.value.toDouble())
                .setSourceCountry("AE")
                .setDestinationCountry(request.delivery.address.countryCode.toString())
                .setCurrency(request.currency.toString())
                .setUrgent(request.delivery.urgent)
                .build()
        )

        return OrderResponse(
            orderId = Order.Id(0L),
            customerId = request.customerId,
            lineItems = request.lineItems.map {
                OrderResponse.LineItem(
                    productId = it.productId,
                    unitWeight = it.unitWeight,
                    units = it.units,
                )
            },
            total = FastMoney.ofMinor(
                Monetary.getCurrency(price.currency),
                price.priceMinorUnits
            )
        )
    }
}
package io.wks.terraform.orderservice.orders.service

import com.neovisionaries.i18n.CountryCode
import io.wks.terraform.orderservice.customers.Customer
import io.wks.terraform.orderservice.orders.Order
import io.wks.terraform.orderservice.products.Kilogram
import io.wks.terraform.orderservice.products.Product
import javax.money.MonetaryAmount

data class OrderResponse(
    val orderId: Order.Id,
    val customerId: Customer.Id,
    val lineItems: Collection<LineItem>,
    val total: MonetaryAmount,
) {
    data class LineItem(
        val productId: Product.SKU,
        val unitWeight: Kilogram,
        val units: Int,
    )

}
package io.wks.terraform.orderservice.orders.service

import io.wks.terraform.orderservice.customers.Customer
import io.wks.terraform.orderservice.delivery.Delivery
import io.wks.terraform.orderservice.orders.CurrencyCode
import io.wks.terraform.orderservice.orders.Order
import io.wks.terraform.orderservice.products.Kilogram
import io.wks.terraform.orderservice.products.Product
import java.math.BigDecimal

data class OrderRequest(
    val customerId: Customer.Id,
    val currency: CurrencyCode,
    val lineItems: Collection<LineItem>,
    val delivery: Delivery,
) {
    data class LineItem(
        val productId: Product.SKU,
        val unitWeight: Kilogram,
        val units: Int,
    )

    val totalWeight by lazy {
        lineItems.fold(Kilogram(BigDecimal.ZERO)) { acc, lineItem -> acc + (lineItem.unitWeight * lineItem.units) }
    }
}
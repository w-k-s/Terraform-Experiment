package io.wks.terraform.orderservice.orders

import io.wks.terraform.orderservice.customers.Customer
import io.wks.terraform.orderservice.delivery.Delivery
import io.wks.terraform.orderservice.products.Kilogram
import io.wks.terraform.orderservice.products.Product
import javax.money.MonetaryAmount

data class Order(
    val id: Id,
    val customerId: Customer.Id,
    val lineItems: Collection<LineItem>,
    val delivery: Delivery,
    val totalCost: MonetaryAmount,
) {
    @JvmInline
    value class Id(val value: Long)
    data class LineItem(
        val orderId: Id,
        val productSku: Product.SKU,
        val unitWeight: Kilogram,
        val units: Int,
    )
}


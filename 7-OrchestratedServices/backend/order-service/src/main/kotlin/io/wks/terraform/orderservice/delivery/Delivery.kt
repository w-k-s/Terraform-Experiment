package io.wks.terraform.orderservice.delivery

data class Delivery(
    val address: Address,
    val urgent: Boolean,
)

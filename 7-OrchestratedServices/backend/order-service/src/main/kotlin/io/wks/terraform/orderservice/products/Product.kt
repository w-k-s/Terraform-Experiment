package io.wks.terraform.orderservice.products

import java.util.UUID

class Product() {
    @JvmInline
    value class SKU(val uuid: UUID)
}
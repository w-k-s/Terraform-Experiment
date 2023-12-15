package io.wks.terraform.orderservice

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication(
    scanBasePackages = [
        "io.wks.terraform.orderservice.orders.api",
        "io.wks.terraform.orderservice.config",
        "io.wks.terraform.orderservice.orders.service"
    ]
)
class OrderServiceApplication

fun main(args: Array<String>) {
    runApplication<OrderServiceApplication>(*args)
}

package io.wks.terraform.orderservice.orders.api

import io.wks.terraform.orderservice.orders.service.OrderRequest
import io.wks.terraform.orderservice.orders.service.OrderService
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/v1/order")
class OrderController(private val orderService: OrderService) {

    @PostMapping
    fun createOrder(@RequestBody request: OrderRequest) = orderService.createOrder(request)
}
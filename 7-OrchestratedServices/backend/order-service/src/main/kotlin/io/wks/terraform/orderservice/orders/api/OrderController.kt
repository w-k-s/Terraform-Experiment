package io.wks.terraform.orderservice.orders.api

import io.wks.terraform.orderservice.orders.service.OrderService
import io.wks.terraform.orderservice.orders.service.OrderRequest
import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping

@Controller
@RequestMapping("/api/v1/order")
class OrderController(private val orderService: OrderService) {

    @PostMapping
    fun createOrder(@RequestBody request: OrderRequest) = orderService.createOrder(request)
}
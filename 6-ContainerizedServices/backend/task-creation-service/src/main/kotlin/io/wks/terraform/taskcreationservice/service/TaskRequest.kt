package io.wks.terraform.taskcreationservice.service

data class TaskRequest(
    val customerId: String,
    val category: String,
    val description: String
)
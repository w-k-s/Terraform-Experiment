package io.wks.terraform.taskcreationservice.dto

data class TaskRequest(
    val customerId: String,
    val category: String,
    val description: String
)
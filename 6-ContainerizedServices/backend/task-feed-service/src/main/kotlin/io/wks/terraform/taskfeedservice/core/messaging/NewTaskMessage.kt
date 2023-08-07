package io.wks.terraform.taskfeedservice.core.messaging

import java.time.OffsetDateTime

data class NewTaskMessage(
    val id: Long,
    val description: String,
    val category: String,
    val createdAt: OffsetDateTime,
    val version: Int
)
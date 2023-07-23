package io.wks.terraform.taskfeedservice.core.messaging

import java.time.OffsetDateTime

data class NewTaskMessage(
    val id: Long,
    val description: String,
    val category: String,
    val created: OffsetDateTime,
    val version: Int
)
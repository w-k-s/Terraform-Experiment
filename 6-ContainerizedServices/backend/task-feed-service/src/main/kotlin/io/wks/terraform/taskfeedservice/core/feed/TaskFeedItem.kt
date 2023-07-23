package io.wks.terraform.taskfeedservice.core.feed

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonValue
import io.wks.terraform.taskfeedservice.core.tasker.Tasker
import org.springframework.data.annotation.Version
import org.springframework.data.relational.core.mapping.Table
import java.time.OffsetDateTime

@Table("task_feed", schema = "task_feed")
data class TaskFeedItem(
    val id: Id,
    val taskerId: Tasker.Id,
    val taskId: Long,
    val description: String,
    val created: OffsetDateTime,
) {
    @Version
    var version: Int? = 0

    class Id @JsonCreator constructor(@JsonValue val value: Long)
}

package io.wks.terraform.taskfeedservice.core.feed

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonValue
import io.wks.terraform.taskfeedservice.core.tasker.Tasker
import org.springframework.data.annotation.Id
import org.springframework.data.annotation.Version
import org.springframework.data.domain.Persistable
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.OffsetDateTime

@Table("task_feed", schema = "task_feed")
data class TaskFeedItem(
    @org.springframework.data.annotation.Id
    @get:JvmName("id")
    val id: Id,
    val taskerId: Tasker.Id,
    val taskId: Long,
    val description: String,
    val createdAt: OffsetDateTime,
) : Persistable<TaskFeedItem.Id> {

    class Id @JsonCreator constructor(@JsonValue val value: Long)

    override fun getId() = id

    // Spring Data is awful!
    override fun isNew() = true
}

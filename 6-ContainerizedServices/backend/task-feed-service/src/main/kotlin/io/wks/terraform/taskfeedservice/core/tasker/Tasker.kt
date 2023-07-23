package io.wks.terraform.taskfeedservice.core.tasker

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonValue
import org.springframework.data.annotation.Version
import org.springframework.data.relational.core.mapping.Table

@Table(name = "tasker", schema = "task_feed")
data class Tasker(
    @org.springframework.data.annotation.Id
    val id: Id,
    val name: String,
    val categories: Set<Category>
) {

    class Id @JsonCreator constructor(@JsonValue val value: Long)

    @Version
    var version: Int? = null
}

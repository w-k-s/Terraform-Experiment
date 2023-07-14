package io.wks.terraform.taskcreationservice.model

import org.springframework.data.annotation.Version
import org.springframework.data.relational.core.mapping.Table
import java.time.OffsetDateTime
import java.time.ZoneOffset

@Table("task", schema = "task_creation")
class Task(
    @org.springframework.data.annotation.Id
    val id: Task.Id,
    val description: String,
    val category: String,
    val createdAt: OffsetDateTime = OffsetDateTime.now(ZoneOffset.UTC)

) {
    /**
     * Required by Spring-Data-Jdbc to determine if the entity is new
     */
    @Version
    var version: Int? = null

    /**
     * Could be a value class once spring-data-jdbc supports it.
     * https://github.com/spring-projects/spring-data-relational/issues/1093
     */
    class Id(val value: Long)
}


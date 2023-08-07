package io.wks.terraform.taskfeedservice.core.tasker

import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table

@Table(name = "tasker_category", schema = "task_feed")
data class Category(
    @Column("tasker_id")
    val taskerId: Tasker.Id,
    val category: String
)

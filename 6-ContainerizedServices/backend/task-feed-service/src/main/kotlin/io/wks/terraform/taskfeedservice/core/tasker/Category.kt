package io.wks.terraform.taskfeedservice.core.tasker

import org.springframework.data.relational.core.mapping.Table

@Table(name = "category", schema = "task_feed")
data class Category(val taskerId: Tasker.Id, val category: String)

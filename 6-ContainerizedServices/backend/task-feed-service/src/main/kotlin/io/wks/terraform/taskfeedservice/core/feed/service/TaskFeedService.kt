package io.wks.terraform.taskfeedservice.core.feed.service

import io.wks.snowflake4j.snowflake.Snowflake
import io.wks.terraform.taskfeedservice.core.feed.TaskFeed
import io.wks.terraform.taskfeedservice.core.feed.TaskFeedItem
import io.wks.terraform.taskfeedservice.core.feed.persistence.TaskFeedRepository
import io.wks.terraform.taskfeedservice.core.messaging.NewTaskMessage
import io.wks.terraform.taskfeedservice.core.tasker.Tasker
import io.wks.terraform.taskfeedservice.core.tasker.service.TaskerService
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.function.Supplier

@Service
class TaskFeedService(
    private val taskerService: TaskerService,
    private val snowflakeFactory: Supplier<Snowflake>,
    private val taskFeedRepository: TaskFeedRepository,
) {
    private val logger = LoggerFactory.getLogger(TaskFeedService::class.java)

    @Transactional
    fun onNewTask(taskMessage: NewTaskMessage) {
        val newFeedItems = taskerService.taskersWithCategory(taskMessage.category)
            .also { logger.info("Found '${it.size}' taskers with category '${taskMessage.category}' ") }
            .map {
                TaskFeedItem(
                    id = TaskFeedItem.Id(snowflakeFactory.get().value),
                    taskerId = it.id,
                    taskId = taskMessage.id,
                    description = taskMessage.description,
                    createdAt = taskMessage.createdAt
                )
            }.toList()

        taskFeedRepository.saveAll(newFeedItems)
    }

    fun taskFeed(taskerId: Tasker.Id) =
        TaskFeed(taskFeedRepository.findAllByTaskerId(taskerId))
}
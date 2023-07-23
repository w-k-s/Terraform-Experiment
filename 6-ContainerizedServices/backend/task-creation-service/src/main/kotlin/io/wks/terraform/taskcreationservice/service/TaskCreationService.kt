package io.wks.terraform.taskcreationservice.service

import io.wks.snowflake4j.snowflake.Snowflake
import io.wks.terraform.taskcreationservice.model.Task
import io.wks.terraform.taskcreationservice.persistence.TaskRepository
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.time.OffsetDateTime
import java.util.function.Supplier


@Service
class TaskCreationService(
    private val snowflakeFactory: Supplier<Snowflake>,
    private val taskRepository: TaskRepository,
    private val clock: Clock,
    private val publishingService: MessagePublishingService,
    @Value("\${messaging.queue.tasks.name}") private val tasksQueueName: String,
) {

    @Transactional
    fun createTask(request: TaskRequest): TaskIdResponse {
        return with(
            Task(
                id = Task.Id(snowflakeFactory.get().value),
                description = request.description,
                category = request.category,
                createdAt = OffsetDateTime.now(clock)
            )
        ) {
            taskRepository.save(this)
            publishingService.publish(
                tasksQueueName,
                this
            )
            TaskIdResponse(taskId = this.id.value)
        }
    }
}
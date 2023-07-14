package io.wks.terraform.taskcreationservice.service

import io.wks.snowflake4j.snowflake.Snowflake
import io.wks.terraform.taskcreationservice.dto.TaskIdResponse
import io.wks.terraform.taskcreationservice.dto.TaskRequest
import io.wks.terraform.taskcreationservice.model.Task
import io.wks.terraform.taskcreationservice.persistence.TaskRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.time.OffsetDateTime
import java.util.function.Supplier

@Service
class TaskCreationService(
    private val snowflakeFactory: Supplier<Snowflake>,
    private val taskRepository: TaskRepository,
    private val clock: Clock
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
            TaskIdResponse(taskId = this.id.value)
        }
    }
}
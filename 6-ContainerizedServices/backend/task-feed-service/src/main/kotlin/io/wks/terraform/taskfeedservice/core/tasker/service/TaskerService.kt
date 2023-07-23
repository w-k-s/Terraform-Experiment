package io.wks.terraform.taskfeedservice.core.tasker.service

import io.wks.snowflake4j.snowflake.Snowflake
import io.wks.terraform.taskfeedservice.core.tasker.Category
import io.wks.terraform.taskfeedservice.core.tasker.Tasker
import io.wks.terraform.taskfeedservice.core.tasker.persistence.TaskerRepository
import org.springframework.stereotype.Service
import java.util.function.Supplier

data class CreateTaskerRequest(
    val name: String,
    val categories: List<String> = emptyList()
)

data class CreateTaskerResponse(
    val id: Long,
    val name: String,
    val categories: List<String> = emptyList()
)

@Service
class TaskerService(
    private val taskerRepository: TaskerRepository,
    private val snowflakeFactory: Supplier<Snowflake>
) {
    fun taskersWithCategory(category: String) =
        taskerRepository.findTaskersByCategoriesContainingIgnoreCase(category)

    fun createTasker(request: CreateTaskerRequest): CreateTaskerResponse {
        val id = Tasker.Id(snowflakeFactory.get().value)
        taskerRepository.save(
            Tasker(
                id = id,
                name = request.name,
                categories = request.categories.map {
                    Category(
                        taskerId = id,
                        category = it
                    )
                }.toSet()
            )
        )

        return CreateTaskerResponse(
            id = id.value,
            name = request.name,
            categories = request.categories
        )
    }
}
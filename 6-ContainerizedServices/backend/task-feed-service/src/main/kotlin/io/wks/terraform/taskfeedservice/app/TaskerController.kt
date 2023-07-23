package io.wks.terraform.taskfeedservice.app

import io.wks.terraform.taskfeedservice.core.tasker.service.CreateTaskerRequest
import io.wks.terraform.taskfeedservice.core.tasker.service.TaskerService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

data class CreateTaskerApiRequest(
    val name: String,
    val categories: List<String> = emptyList()
)

@RestController
@RequestMapping(
    "/api"
)
class TaskerController(private val taskerService: TaskerService) {

    @PostMapping("/v1/taskers")
    fun createTask(@RequestBody request: CreateTaskerApiRequest): ResponseEntity<Any> {
        return ResponseEntity.ok(taskerService.createTasker(
            CreateTaskerRequest(
                name = request.name,
                categories = request.categories,
            )))
    }
}
package io.wks.terraform.taskcreationservice.api

import io.wks.terraform.taskcreationservice.dto.TaskRequest
import io.wks.terraform.taskcreationservice.service.TaskCreationService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping(
    "/api"
)
class TaskController(private val taskCreationService: TaskCreationService) {

    @PostMapping("/v1/tasks")
    fun createTask(@RequestBody request: TaskRequest): ResponseEntity<Any> {
        return ResponseEntity.ok(taskCreationService.createTask(request))
    }
}

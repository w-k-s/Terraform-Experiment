package io.wks.terraform.taskfeedservice.app

import io.wks.terraform.taskfeedservice.core.feed.service.TaskFeedService
import io.wks.terraform.taskfeedservice.core.tasker.Tasker
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping(
    "/api"
)
class TaskFeedController(private val taskFeedService: TaskFeedService) {

    @PostMapping("/v1/taskers")
    fun createTask(@RequestParam("taskerId", required = true) taskerId: Long): ResponseEntity<Any> {
        return ResponseEntity.ok(taskFeedService.taskFeed(Tasker.Id(taskerId)))
    }
}
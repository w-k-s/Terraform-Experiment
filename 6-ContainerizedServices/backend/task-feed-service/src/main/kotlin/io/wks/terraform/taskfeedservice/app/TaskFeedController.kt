package io.wks.terraform.taskfeedservice.app

import io.wks.terraform.taskfeedservice.core.feed.service.TaskFeedService
import io.wks.terraform.taskfeedservice.core.tasker.Tasker
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping(
    "/api"
)
class TaskFeedController(private val taskFeedService: TaskFeedService) {

    @GetMapping("/v1/taskers/{taskerId}/feed")
    fun taskFeed(@PathVariable("taskerId", required = true) taskerId: Long): ResponseEntity<Any> {
        return ResponseEntity.ok(taskFeedService.taskFeed(Tasker.Id(taskerId)))
    }
}
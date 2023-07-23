package io.wks.terraform.taskfeedservice

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication(
    scanBasePackages = [
        "io.wks.terraform.taskfeedservice.app",
        "io.wks.terraform.taskfeedservice.config",
        "io.wks.terraform.taskfeedservice.core.feed",
        "io.wks.terraform.taskfeedservice.core.tasker",
    ]
)
class TaskFeedServiceApplication

fun main(args: Array<String>) {
    runApplication<TaskFeedServiceApplication>(*args)
}

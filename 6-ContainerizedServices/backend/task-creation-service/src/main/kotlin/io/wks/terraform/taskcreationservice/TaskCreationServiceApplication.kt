package io.wks.terraform.taskcreationservice

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.context.annotation.ComponentScan

@ComponentScan(
    basePackages = [
        "io.wks.terraform.taskcreationservice.model",
        "io.wks.terraform.taskcreationservice.service",
        "io.wks.terraform.taskcreationservice.persistence",
        "io.wks.terraform.taskcreationservice.api",
        "io.wks.terraform.taskcreationservice.config",
    ]
)
@SpringBootApplication(
    scanBasePackages = [
        "io.wks.terraform.taskcreationservice.model",
        "io.wks.terraform.taskcreationservice.service",
        "io.wks.terraform.taskcreationservice.persistence",
        "io.wks.terraform.taskcreationservice.api",
        "io.wks.terraform.taskcreationservice.config",
    ]
)
class TaskCreationServiceApplication

fun main(args: Array<String>) {
    runApplication<TaskCreationServiceApplication>(*args)
}

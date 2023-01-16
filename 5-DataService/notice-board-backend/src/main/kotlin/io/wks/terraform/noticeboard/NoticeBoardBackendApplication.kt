package io.wks.terraform.noticeboard

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
open class NoticeBoardBackendApplication

fun main(args: Array<String>) {
    runApplication<NoticeBoardBackendApplication>(*args)
}

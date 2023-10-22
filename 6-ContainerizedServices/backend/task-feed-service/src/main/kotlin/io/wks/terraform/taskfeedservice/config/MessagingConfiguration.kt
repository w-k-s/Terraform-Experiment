package io.wks.terraform.taskfeedservice.config

import io.awspring.cloud.sqs.listener.errorhandler.ErrorHandler
import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.messaging.Message


@Configuration
class MessagingConfiguration {

    private val logger = LoggerFactory.getLogger(MessagingConfiguration::class.java)

    @Bean
    fun errorHandler(): ErrorHandler<Object> = object: ErrorHandler<Object>{
        override fun handle(message: Message<Object>, t: Throwable) {
            logger.info("Error processing message: "+message, t)
        }
    }
}
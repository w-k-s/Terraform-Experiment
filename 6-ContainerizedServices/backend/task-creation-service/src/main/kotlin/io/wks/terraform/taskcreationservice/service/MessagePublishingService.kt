package io.wks.terraform.taskcreationservice.service

import io.awspring.cloud.messaging.core.QueueMessagingTemplate
import org.springframework.stereotype.Service

@Service
class MessagePublishingService(
    private val messageTemplate: QueueMessagingTemplate
) {

    fun <T : Any> publish(
        queue: String,
        payload: T,
        headers: Map<String, String> = emptyMap()
    ) {

        messageTemplate.convertAndSend(
            queue,
            payload,
            headers
        )
    }
}
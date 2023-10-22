package io.wks.terraform.taskfeedservice.core.messaging.service

import io.awspring.cloud.sqs.annotation.SqsListener
import io.wks.terraform.taskfeedservice.core.feed.service.TaskFeedService
import io.wks.terraform.taskfeedservice.core.messaging.NewTaskMessage
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

@Service
class MessageReceiver(
    private val taskFeedService: TaskFeedService
) {

    private val LOGGER = LoggerFactory.getLogger(MessageReceiver::class.java)

    @SqsListener(
        value = ["\${messaging.queue.tasks.name}"]
    )
    fun receiveMessage(
        message: NewTaskMessage
    ) {
        LOGGER.info("Message Received: '$message'")
        taskFeedService.onNewTask(message)
    }
}
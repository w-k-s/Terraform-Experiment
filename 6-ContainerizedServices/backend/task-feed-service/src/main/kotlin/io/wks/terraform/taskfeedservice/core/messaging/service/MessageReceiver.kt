package io.wks.terraform.taskfeedservice.core.messaging.service

import io.awspring.cloud.messaging.listener.SqsMessageDeletionPolicy
import io.awspring.cloud.messaging.listener.annotation.SqsListener
import io.wks.terraform.taskfeedservice.core.feed.service.TaskFeedService
import io.wks.terraform.taskfeedservice.core.messaging.NewTaskMessage
import org.springframework.messaging.handler.annotation.Header
import org.springframework.stereotype.Service

@Service
class MessageReceiver(
    private val taskFeedService: TaskFeedService
) {

    @SqsListener(
        value = ["\${messaging.queue.tasks.name}"],
        deletionPolicy = SqsMessageDeletionPolicy.ON_SUCCESS
    )
    fun receiveMessage(
        message: NewTaskMessage,
        @Header("SenderId") senderId: String?
    ) {
        taskFeedService.onNewTask(message)
    }
}
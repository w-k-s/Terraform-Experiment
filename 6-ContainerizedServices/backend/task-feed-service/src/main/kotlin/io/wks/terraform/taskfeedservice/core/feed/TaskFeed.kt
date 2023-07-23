package io.wks.terraform.taskfeedservice.core.feed

class TaskFeed(private val feed: List<TaskFeedItem> = emptyList()) : AbstractList<TaskFeedItem>() {

    override val size: Int
        get() = feed.size

    override fun get(index: Int) = feed.get(index)
}
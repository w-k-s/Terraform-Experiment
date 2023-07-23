package io.wks.terraform.taskfeedservice.core.feed.persistence

import io.wks.terraform.taskfeedservice.core.feed.TaskFeedItem
import io.wks.terraform.taskfeedservice.core.tasker.Tasker
import org.springframework.core.convert.converter.Converter
import org.springframework.data.convert.ReadingConverter
import org.springframework.data.convert.WritingConverter
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Component
import org.springframework.stereotype.Repository

@Repository
interface TaskFeedRepository : CrudRepository<TaskFeedItem, TaskFeedItem.Id>{
    fun findAllByTaskerId(taskerId: Tasker.Id): List<TaskFeedItem>
}

@Component
@WritingConverter
class TaskFeedIdWritingConverter : Converter<TaskFeedItem.Id, Long> {
    override fun convert(source: TaskFeedItem.Id) = source.value
}

@Component
@ReadingConverter
class TaskFeedIdReadingConverter : Converter<Long, TaskFeedItem.Id> {
    override fun convert(source: Long) = TaskFeedItem.Id(source)
}
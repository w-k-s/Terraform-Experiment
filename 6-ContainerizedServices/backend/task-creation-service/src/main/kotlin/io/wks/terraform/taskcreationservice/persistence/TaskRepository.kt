package io.wks.terraform.taskcreationservice.persistence

import io.wks.terraform.taskcreationservice.model.Task
import org.springframework.core.convert.converter.Converter
import org.springframework.data.convert.ReadingConverter
import org.springframework.data.convert.WritingConverter
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Component
import org.springframework.stereotype.Repository

@Repository
interface TaskRepository : CrudRepository<Task, Task.Id>

@Component
@WritingConverter
class TaskIdWritingConverter : Converter<Task.Id, Long> {
    override fun convert(source: Task.Id) = source.value
}

@Component
@ReadingConverter
class TaskIdReadingConverter : Converter<Long, Task.Id> {
    override fun convert(source: Long) = Task.Id(source)
}
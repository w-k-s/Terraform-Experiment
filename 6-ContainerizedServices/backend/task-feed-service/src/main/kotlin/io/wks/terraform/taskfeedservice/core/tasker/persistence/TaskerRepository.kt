package io.wks.terraform.taskfeedservice.core.tasker.persistence

import io.wks.terraform.taskfeedservice.core.tasker.Tasker
import org.springframework.core.convert.converter.Converter
import org.springframework.data.convert.ReadingConverter
import org.springframework.data.convert.WritingConverter
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Component
import org.springframework.stereotype.Repository

@Repository
interface TaskerRepository : CrudRepository<Tasker, Tasker.Id> {
    fun findTaskersByCategoriesContainingIgnoreCase(name: String): List<Tasker>
}

@Component
@WritingConverter
class TaskerIdWritingConverter : Converter<Tasker.Id, Long> {
    override fun convert(source: Tasker.Id) = source.value
}

@Component
@ReadingConverter
class TaskerIdReadingConverter : Converter<Long, Tasker.Id> {
    override fun convert(source: Long) = Tasker.Id(source)
}
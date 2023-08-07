package io.wks.terraform.taskfeedservice.core.tasker.persistence

import io.wks.terraform.taskfeedservice.core.tasker.Tasker
import org.springframework.core.convert.converter.Converter
import org.springframework.data.convert.ReadingConverter
import org.springframework.data.convert.WritingConverter
import org.springframework.data.jdbc.repository.query.Query
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Component
import org.springframework.stereotype.Repository

@Repository
interface TaskerRepository : CrudRepository<Tasker, Tasker.Id> {
    @Query("SELECT t.* FROM task_feed.tasker t INNER JOIN task_feed.tasker_category c ON c.tasker_id = t.id WHERE c.category = :name")
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
package io.wks.terraform.todobackend.todo

import org.springframework.core.convert.converter.Converter
import org.springframework.data.convert.ReadingConverter
import org.springframework.data.convert.WritingConverter
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository


@Repository
interface TodoDao : CrudRepository<Todo, TodoId>

@WritingConverter
class TodoIdToLongConverter : Converter<TodoId, Long> {
    override fun convert(source: TodoId) = source.value
}

@ReadingConverter
class LongToTodoIdConverter : Converter<Long, TodoId> {
    override fun convert(source: Long) = TodoId(source)
}
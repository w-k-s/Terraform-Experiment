package io.wks.terraform.todobackend.todo

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonValue
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.JsonDeserializer
import com.fasterxml.jackson.databind.annotation.JsonDeserialize
import org.springframework.data.annotation.Id
import java.time.Clock
import java.time.OffsetDateTime

data class TodoId @JsonCreator constructor(@JsonValue val value: Long) {
    override fun toString() = value.toString()
}

class TodoIdDeserializer : JsonDeserializer<TodoId>() {
    override fun deserialize(parser: JsonParser?, context: DeserializationContext?): TodoId? {
        return parser?.text?.toLongOrNull()?.let { TodoId(it) }
    }
}

data class Todo(
    @Id
    @JsonDeserialize(using = TodoIdDeserializer::class)
    val id: TodoId? = null, // TODO: Not nice, make it not-nullable
    val description: String,
    val createdAt: OffsetDateTime,
    val completedAt: OffsetDateTime? = null,
) {
    init {
        require(description.isNotBlank()) { "A description is required" }
    }

    companion object {
        fun create(description: String, clock: Clock = Clock.systemUTC()) =
            Todo(description = description, createdAt = OffsetDateTime.now(clock))
    }

    fun complete(clock: Clock = Clock.systemUTC()) = copy(completedAt = OffsetDateTime.now(clock))
}

data class Todos(val todos: Collection<Todo>) : Collection<Todo> {
    override val size = todos.size
    override fun contains(element: Todo) = todos.contains(element)
    override fun containsAll(elements: Collection<Todo>) = todos.containsAll(elements)
    override fun isEmpty() = todos.isEmpty()
    override fun iterator() = todos.iterator()
}
package io.wks.terraform.todobackend.todo

import jakarta.validation.ConstraintViolationException
import org.springframework.http.HttpStatus
import org.springframework.http.ProblemDetail
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.*


@Controller
@RequestMapping("/api/v1/todos")
class TodoController(private var todoService: TodoService) {

    @PostMapping
    fun create(@RequestBody request: TodoRequest): ResponseEntity<TodoResponse> {
        return ResponseEntity.ok(todoService.createTodo(request))
    }

    @GetMapping
    fun list() = ResponseEntity.ok(todoService.list())

    @PatchMapping("/{id}/complete")
    fun complete(@PathVariable("id") id: Long): ResponseEntity<TodoResponse> {
        return ResponseEntity.ok(TodoResponse(todoService.completeTodo(TodoId(id))))
    }

    @DeleteMapping("/{id}")
    fun delete(@PathVariable("id") id: Long): ResponseEntity<Unit> {
        todoService.deleteTodo(TodoId(id))
        return ResponseEntity.noContent().build()
    }

    @ExceptionHandler(ConstraintViolationException::class)
    fun validationError(e: ConstraintViolationException): ProblemDetail {

        return ProblemDetail.forStatusAndDetail(
            HttpStatus.BAD_REQUEST,
            "The information provided is incorrect"
        ).also {
            e.constraintViolations.forEach { field ->
                it.setProperty(field.propertyPath.toString(), field.message)
            }
        }
    }

    @ExceptionHandler(TodoNotFoundException::class)
    fun notFoundError(e: TodoNotFoundException): ProblemDetail {

        return ProblemDetail.forStatusAndDetail(
            HttpStatus.NOT_FOUND,
            e.message ?: "Task not found"
        )
    }
}

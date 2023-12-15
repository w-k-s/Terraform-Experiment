package io.wks.terraform.orderservice.config

import io.grpc.Status
import io.grpc.StatusRuntimeException
import org.springframework.http.HttpStatus
import org.springframework.http.ProblemDetail
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler


@RestControllerAdvice
class DefaultControllerAdvice : ResponseEntityExceptionHandler() {
    @ExceptionHandler(StatusRuntimeException::class)
    fun handleNotFoundException(e: StatusRuntimeException): ProblemDetail {
        return when (e.status.code) {
            Status.Code.INVALID_ARGUMENT -> ProblemDetail.forStatusAndDetail(
                HttpStatus.BAD_REQUEST,
                e.status.description ?: "Invalid argument",
            )

            else -> ProblemDetail.forStatusAndDetail(
                HttpStatus.INTERNAL_SERVER_ERROR,
                e.message ?: "Internal Server Error",
            )
        }.also {
            it.title = e.status?.code?.name
        }
    }
}
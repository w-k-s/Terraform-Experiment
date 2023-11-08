package io.wks.terraform.shippingprice

import io.grpc.Status
import io.grpc.StatusException
import net.devh.boot.grpc.server.advice.GrpcAdvice
import net.devh.boot.grpc.server.advice.GrpcExceptionHandler

@GrpcAdvice
class GrpcExceptionAdvice {

    @GrpcExceptionHandler(BusinessRuleViolationException::class)
    fun handleResourceNotFoundException(e: BusinessRuleViolationException): StatusException {
        val status = Status.INVALID_ARGUMENT.withDescription(e.message).withCause(e)
        return status.asException(null)
    }

}

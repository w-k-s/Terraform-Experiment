package io.wks.terraform.taskfeedservice.config

import com.amazonaws.auth.DefaultAWSCredentialsProviderChain
import com.amazonaws.regions.Regions
import com.amazonaws.services.sqs.AmazonSQSAsync
import com.amazonaws.services.sqs.AmazonSQSAsyncClientBuilder
import com.fasterxml.jackson.databind.ObjectMapper
import io.awspring.cloud.messaging.config.QueueMessageHandlerFactory
import io.awspring.cloud.messaging.core.QueueMessagingTemplate
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.messaging.converter.MappingJackson2MessageConverter
import org.springframework.messaging.converter.MessageConverter
import org.springframework.messaging.handler.annotation.support.PayloadMethodArgumentResolver
import org.springframework.messaging.handler.invocation.HandlerMethodArgumentResolver


@Configuration
class MessagingConfiguration {

    @Bean
    fun amazonSQSAsync(): AmazonSQSAsync {
        return AmazonSQSAsyncClientBuilder
            .standard()
            .withRegion(Regions.AP_SOUTH_1)
            .withCredentials(DefaultAWSCredentialsProviderChain())
            .build()
    }

    @Bean
    fun queueMessagingTemplate(amazonSQSAsync: AmazonSQSAsync) = QueueMessagingTemplate(amazonSQSAsync)

    @Bean
    fun queueMessageHandlerFactory(
        mapper: ObjectMapper,
        amazonSQSAsync: AmazonSQSAsync?
    ): QueueMessageHandlerFactory? {
        val queueHandlerFactory = QueueMessageHandlerFactory()
        queueHandlerFactory.setAmazonSqs(amazonSQSAsync)
        queueHandlerFactory.setArgumentResolvers(
            listOf<HandlerMethodArgumentResolver>(
                PayloadMethodArgumentResolver(jackson2MessageConverter(mapper))
            )
        )
        return queueHandlerFactory
    }

    private fun jackson2MessageConverter(mapper: ObjectMapper): MessageConverter {
        val converter = MappingJackson2MessageConverter()
        converter.objectMapper = mapper
        return converter
    }
}
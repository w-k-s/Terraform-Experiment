package io.wks.terraform.taskfeedservice.config

import com.fasterxml.jackson.databind.ObjectMapper
import io.awspring.cloud.sqs.config.SqsBootstrapConfiguration
import io.awspring.cloud.sqs.config.SqsMessageListenerContainerFactory
import io.awspring.cloud.sqs.support.converter.SqsMessagingMessageConverter
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Import
import org.springframework.messaging.converter.MappingJackson2MessageConverter
import org.springframework.messaging.converter.MessageConverter
import software.amazon.awssdk.services.sqs.SqsAsyncClient


@Import(SqsBootstrapConfiguration::class)
@Configuration
class MessagingConfiguration {

    @Bean
    fun defaultSqsListenerContainerFactory(mapper: ObjectMapper): SqsMessageListenerContainerFactory<Any>? {
        return SqsMessageListenerContainerFactory
            .builder<Any>()
            .sqsAsyncClient(sqsAsyncClient()!!)
            .configure{
                it.messageConverter(SqsMessagingMessageConverter().apply {
                    this.setObjectMapper(mapper)
                })
            }
            .build()
    }

    @Bean
    fun sqsAsyncClient(): SqsAsyncClient? {
        return SqsAsyncClient.builder()
            .build()
    }
}
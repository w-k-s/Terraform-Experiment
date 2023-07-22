package io.wks.terraform.taskcreationservice.config

import com.amazonaws.auth.DefaultAWSCredentialsProviderChain
import com.amazonaws.regions.Regions
import com.amazonaws.services.sqs.AmazonSQSAsync
import com.amazonaws.services.sqs.AmazonSQSAsyncClientBuilder
import com.fasterxml.jackson.databind.ObjectMapper
import io.awspring.cloud.core.env.ResourceIdResolver
import io.awspring.cloud.core.env.StackResourceRegistryDetectingResourceIdResolver
import io.awspring.cloud.messaging.core.QueueMessagingTemplate
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.messaging.converter.MappingJackson2MessageConverter
import org.springframework.messaging.converter.MessageConverter


@Configuration
class MessagingConfiguration {

    @Bean
    fun queueMessagingTemplate(
        amazonSQSAsync: AmazonSQSAsync,
        objectMapper: ObjectMapper
    ): QueueMessagingTemplate {
        val converter = MappingJackson2MessageConverter().also {
            it.serializedPayloadClass = String::class.java
            it.objectMapper = objectMapper
        }

        return QueueMessagingTemplate(
            amazonSQSAsync,
            StackResourceRegistryDetectingResourceIdResolver(),
            converter
        )
    }

    @Bean
    fun amazonSQSAsync(): AmazonSQSAsync? {
        return AmazonSQSAsyncClientBuilder
            .standard()
            .withRegion(Regions.AP_SOUTH_1)
            .withCredentials(DefaultAWSCredentialsProviderChain())
            .build()
    }
}
package io.wks.terraform.noticeboard.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.web.SecurityFilterChain


@Configuration
@EnableWebSecurity
open class SecurityConfiguration {

    @Bean
    open fun filterChain(http: HttpSecurity): SecurityFilterChain? {
        http
            .cors()
            .and()
            .csrf()
            .disable()
            .authorizeHttpRequests {
                it.anyRequest().authenticated()
            }
            .oauth2ResourceServer().jwt()
        return http.build()
    }
}
package io.wks.terraform.noticeboard.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.data.domain.AuditorAware
import org.springframework.data.jpa.repository.config.EnableJpaAuditing
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken
import java.util.*

class JwtAuditorAware : AuditorAware<String> {
    override fun getCurrentAuditor(): Optional<String> =
        Optional.ofNullable((SecurityContextHolder.getContext().authentication as? JwtAuthenticationToken)?.name)

}

@Configuration
@EnableJpaAuditing
open class AuditConfiguration {

    @Bean
    open fun auditorAware(): AuditorAware<String> {
        return JwtAuditorAware()
    }
}
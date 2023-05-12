package io.wks.terraform.noticeboard

import jakarta.persistence.Entity
import jakarta.persistence.EntityListeners
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import org.springframework.data.annotation.CreatedBy
import org.springframework.data.jpa.domain.support.AuditingEntityListener

@Entity(name = "notice")
@EntityListeners(AuditingEntityListener::class)
class Notice(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,
    val notice: String,

    @CreatedBy
    var createdBy: String?,
) {
    constructor() : this(0, "", null)
}
package io.wks.terraform.noticeboard

import jakarta.persistence.*
import org.springframework.data.annotation.CreatedBy
import org.springframework.data.jpa.domain.support.AuditingEntityListener

@Entity
@Table(name = "notice", schema = "noticeboard")
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
package io.wks.terraform.noticeboard

import org.springframework.data.repository.CrudRepository
import org.springframework.data.rest.core.annotation.RepositoryRestResource

@RepositoryRestResource(collectionResourceRel = "notice", path = "notices")
interface NoticeRepository : CrudRepository<Notice, Long>
package io.wks.terraform.orderservice.delivery

@JvmInline
value class CountryCode private constructor(private val value: com.neovisionaries.i18n.CountryCode) {
    companion object {
        fun of(value: String) = CountryCode(com.neovisionaries.i18n.CountryCode.getByCode(value, false))
    }

    override fun toString(): String = value.alpha2
}
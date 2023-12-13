package io.wks.terraform.orderservice.orders

@JvmInline
value class CurrencyCode private constructor(private val value: com.neovisionaries.i18n.CurrencyCode) {
    companion object {
        fun of(value: String) = CurrencyCode(com.neovisionaries.i18n.CurrencyCode.valueOf(value))
    }

    override fun toString() = value.toString()
}

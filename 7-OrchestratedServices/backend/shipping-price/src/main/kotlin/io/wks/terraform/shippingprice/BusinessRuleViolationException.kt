package io.wks.terraform.shippingprice

class BusinessRuleViolationException(val rule: Rule) : Exception(rule.message) {

    sealed class Rule(val code: Int, val message: String)

    companion object {
        class UnsupportedDestination(
            sourceCountry: String,
            destinationCountry: String
        ) : Rule(code = 1, "Packages can not be delivered from '$sourceCountry' to '$destinationCountry'")
    }

}
require 'money'
require 'money/bank/open_exchange_rates_bank'

Money.infinite_precision = true
Money.rounding_mode = BigDecimal::ROUND_HALF_UP

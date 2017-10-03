# this operation will retry an individual payment that has failed for any reason
# the retry is instant - as in, even scheduled payments will be retried instantly

class BankTransfer::Payments::Retry < BankTransfer::Payments::Base


end
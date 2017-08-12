# this operation will create the payment order parameters from the account ids and
# the respective amounts
# parameters format:
# params: {
#
#   orders: [
#     {
#     account_id:
#     amount:
#     },
#     .
#     .
#     .
#     and so on..
#   ]
#
#
#
# }
class BankTransfer::YesBank::CreateFromAccountIds < BankTransfer::YesBank::Base

  attr_accessor :bank_accounts

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init

  end

end
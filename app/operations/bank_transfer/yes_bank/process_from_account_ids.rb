# this operation will create the payment order parameters from the account ids and
# the respective amounts
# parameters format:
# params: {
#   account_owner_type: 1 for User, 2 for vendor
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
class BankTransfer::YesBank::ProcessFromAccountIds < BankTransfer::YesBank::Base

  attr_accessor :bank_accounts, :account_ids, :amounts, :response_presenter, :parsed_data

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
      return
    end
    if params[:orders].blank? || params[:account_owner_type].blank?
      add_message :error, "No bank account selected"
    end
  end

  def init
    self.account_ids = retrieve_data(:account_id)
    self.amounts = retrieve_data(:amount)
  end

  def process
    # this will create the data in the format we want and process it
    self.parsed_data = parse_order_information
    params[:payment_order] = self.parsed_data
    self.response_presenter = BankTransfer::YesBank::Process.(user, params)
  end

  def success
    response_presenter
  end

  def failure
    response_presenter || nil
  end

  private

  def retrieve_data(key)
    data = []
    params[:orders].each do |order|
      data << order[key.to_sym]
    end
    data
  end

  def parse_order_information
    data = []
    account_ids.each_with_index do |account_id, index|
      bank_account = BankAccount.find_by(id: account_id)
      data << {
          name: bank_account.account_owner.name,
          account_number: bank_account.account_number,
          ifsc: bank_account.ifsc,
          amount: amounts[index]
      }
    end
    data
  end

end
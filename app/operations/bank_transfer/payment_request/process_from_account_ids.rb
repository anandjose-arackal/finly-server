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
class BankTransfer::PaymentRequest::ProcessFromAccountIds < BankTransfer::PaymentRequest::Base

  attr_accessor :bank_accounts, :account_ids, :amounts, :response_presenter, :parsed_data,
                :notes


  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
      return
    end
    if params[:payment_order].blank? || params[:account_owner_type].blank?
      add_message :error, "No bank account selected"
    end
  end

  def init
    self.account_ids = retrieve_data(:account_id)
    self.amounts = retrieve_data(:original_amount)
    self.notes = retrieve_data(:note)
    [:tax_amount, :tds_amount, :gst_type_id, :discount_amount, :discount, :tax, :tds, :advance_amount, :advance, :freight, :invoice_date, :invoice_number, :due_date, :custom_fields].each do |attr|
      self.class.send(:attr_accessor, attr)
      instance_variable_set("@#{attr}", retrieve_data(attr))
    end
  end

  def process
    # this will create the data in the format we want and process it
    self.parsed_data = parse_order_information
    params[:payment_order] = self.parsed_data
    self.response_presenter = BankTransfer::PaymentRequest::Process.(user, params)
    unless self.response_presenter&.success?
      add_message :error, (self.response_presenter&.messages[:error] || "Unknown failure")
    end
  end

  def success
    response_presenter
  end


  private

  def retrieve_data(key)
    data = []
    params[:payment_order].each do |k, order|
      data << order[key.to_sym]
    end
    data
  end

  def parse_order_information
    data = []
    account_ids.each_with_index do |account_id, index|
      bank_account = BankAccount.find_by(id: account_id)
      data << {
          owner_name: bank_account.account_owner.name,
          name: bank_account.name,
          bank_account_number: bank_account.account_number,
          ifsc: bank_account.ifsc,
          original_amount: amounts[index],
          note: self.notes[index],
          gst_type_id: self.gst_type_id[index],
          tax_amount: self.tax_amount[index],
          discount_amount: self.discount_amount[index],
          tds_amount: self.tds_amount[index],
          tax: self.tax[index],
          tds: self.tds[index],
          discount: self.discount[index],
          advance_amount: self.advance_amount[index],
          advance: self.advance[index],
          freight: self.freight[index],
          invoice_number: self.invoice_number[index],
          invoice_date: self.invoice_date[index],
          due_date: self.due_date[index],
          custom_fields: self.custom_fields[index]
      }
    end
    data
  end

end
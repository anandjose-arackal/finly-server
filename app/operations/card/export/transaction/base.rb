class Card::Export::Transaction::Base < Card::Export::Base

  def retrieve_data(preferences, card_transaction)
    data_arr = []
    preferences.each do |pref|
      case pref
        when 'ATM Terminal'
          data_arr << card_transaction.merchant_name
        when 'Amount'
          data_arr << card_transaction.transaction_amount.value
        when 'User Name'
          data_arr << card_transaction.user.name
        when 'Mobile Number'
          data_arr << card_transaction.user.mobile_number
        when 'Serial ID'
          data_arr << card_transaction.serial_id
        when 'Transaction Time'
          data_arr << card_transaction.transaction_timestamp
        else
          data_arr << ''
      end
    end
    data_arr
  end


  class Card::Export::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header, :file_name

    def init
      self.data = params[:data]
      self.header = params[:header]
      self.file_name = params[:file_name]
    end
  end 
end
class Expense::Export::Base < BaseOperation

  def retrieve_data(preferences, expense)
    data_arr = []
    preferences.each do |pref|
      case pref
        when 'Merchant'
          data_arr << expense.merchant_name
        when 'Amount'
          data_arr << expense.amount.value
        when 'User'
          data_arr << expense.user.name
        when 'Mobile'
          data_arr << expense.user.mobile_number
        when 'Surcharge'
          data_arr << expense.card_expense.surcharge.value
        when 'Created At'
          data_arr << expense.created_at
        else
          data_arr << ''
      end
    end
    data_arr
  end


  class Expense::Export::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header, :file_name

    def init
      self.data = params[:data]
      self.header = params[:header]
      self.file_name = params[:file_name]
    end
  end
end
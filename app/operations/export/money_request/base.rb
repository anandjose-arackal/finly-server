class Export::MoneyRequest::Base < Export::Base
  attr_accessor :company, :preference


  class Export::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header, :money_request_name

    def init
      self.data = params[:data]
      self.header = params[:header]
      self.money_request_name = params[:money_request_name]
    end
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "User or parameters not present."
    end
  end

  def retrieve_data(money_request)
    data_arr = []
    data_arr << money_request.id
    data_arr << money_request.name
    data_arr << money_request.user.first_name
    data_arr << money_request.status&.name
    data_arr << money_request.base_currency&.country_code
    data_arr << money_request.total_amount
    data_arr << money_request.processed_amount&.currency
    data_arr << money_request.processed_amount&.value
    data_arr << money_request.required_by_date
    data_arr << money_request.purpose
    data_arr << money_request.destination_pocket&.name
    data_arr << money_request.payment_mode&.name&.upcase
    data_arr
  end

  def header
    %w(ID Name User Status Requested\ Amount\ Currency Requested\ Amount Processed\ Amount\ Currency Processed\ Amount Required\ By\ Date Purpose Destination\ Account Payment\ Type)
  end

end

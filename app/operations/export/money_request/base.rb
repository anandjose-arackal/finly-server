class Export::MoneyRequest::Base < Export::Base
  attr_accessor :company, :preference, :item_categories


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
    data_arr += retrieve_category_item_value(money_request.items)
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
   header= %w(ID Name User Status Requested\ Amount\ Currency Requested\ Amount Processed\ Amount\ Currency Processed\ Amount Required\ By\ Date Purpose Destination\ Account Payment\ Type)
    self.item_categories = user.company.money_request_item_categories
    header.insert(4, *(item_categories.pluck(:name)))
  end

  def retrieve_category_item_value(money_request_items)
    item_amounts = []
    item_categories.each do |item_category|
      money_request_item  = money_request_items.find{|mr| mr.money_request_item_category_id == item_category.id}
      item_amounts << (money_request_item.present? ? money_request_item.amount.value : '0.0')
    end
    item_amounts
  end

end

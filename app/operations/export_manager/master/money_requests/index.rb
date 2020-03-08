class ExportManager::Master::MoneyRequests::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Money Request Export'
  configurable true
  system :em
  screen 'money_requests.index'
  handle :money_requests
  validate :input

  attribute :money_request_id
  attribute :money_request_name
  attribute :money_request_user
  attribute :money_request_status
  attribute :currency_requested
  attribute :requested_amount
  attribute :processed_amount_currency
  attribute :processed_amount
  attribute :required_by_date
  attribute :purpose
  attribute :destination_account
  attribute :account_payment_type

  section :money_request_item_categories do
    attribute :item_categories, dynamic: true
  end

  def item_categories(row, money_request)
    @categories ||= user.company.money_request_item_categories

    @categories.each do |category|
      item = money_request&.items.find {|mr| mr.money_request_item_category_id == category.id}
      value = item.present? ? item.amount&.value : '0.0'
      row.add(category&.name, value)
    end
  end

  def input
    id = (params[:money_request_ids] or params[:money_request_id] or params[:with_id]).split(',').compact rescue nil 
    params[:filter_ids] = id if id.present?

    result = ::MoneyRequests::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    result.money_requests.include_details
  end

  def money_request_id(money_request)
    money_request.id
  end

  def money_request_name(money_request)
    money_request.name
  end

  def money_request_user(money_request)
    money_request.user&.first_name
  end

  def money_request_status(money_request)
    money_request.status&.name&.humanize
  end

  def currency_requested(money_request)
    money_request.base_currency&.country_code
  end

  def requested_amount(money_request)
    money_request.total_amount
  end

  def processed_amount_currency(money_request)
    money_request.processed_amount&.currency
  end

  def processed_amount(money_request)
    money_request.processed_amount&.value
  end

  def required_by_date(money_request)
    money_request.required_by_date
  end

  def purpose(money_request)
    money_request.purpose
  end

  def destination_account(money_request)
    money_request.destination_pocket&.name
  end

  def account_payment_type(money_request)
    money_request.payment_mode&.name&.upcase
  end

end
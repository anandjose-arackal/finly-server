class ExportManager::Master::MoneyRequests::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Money Request Export'
  configurable true
  system :em
  screen 'money_requests.index'
  handle :money_requests
  validate :input

  attribute :finly_ref_no
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
  attribute :bank_reference_number
  attribute :source_account
  attribute :settlement_date
  attribute :finance_approved_date

  section :money_request_item_categories do
    attribute :item_categories, dynamic: true
  end

  section :money_request_approvers do
    attribute :reviewal_chain, dynamic: true
  end

  def item_categories(row, money_request)
    @categories ||= user.company.money_request_item_categories

    @categories.each do |category|
      item = money_request&.items.find {|mr| mr.money_request_item_category_id == category.id}
      value = item.present? ? item.amount&.value : '0.0'
      row.add(category&.name, value)
    end
  end

  def reviewal_chain(row, money_request)
    money_request&.dlrms.group_by(&:level_number).map do |level_number, group|
      reviewer_name = group.map(&:reviewer).map(&:name).join(", ")
      dlrm = group.find {|d| d if d.action_taken_by_id.present?}
      action_taker = dlrm&.action_taken_by&.name
      action = dlrm&.action&.name&.humanize 
      action_date = dlrm&.action_taken_at&.strftime("%d-%m-%Y, %H:%M")
      row.add("Action Name for Level #{level_number}", action)
      row.add("Action Taken By for Level #{level_number}", action_taker)
      row.add("Action Date for Level #{level_number} (dd/mm/yyyy)", action_date)
      row.add("Reviewer(s) for Level #{level_number}", reviewer_name)
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

  def finly_ref_no(money_request)
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
    money_request.required_by_date&.strftime("%d-%b-%Y")
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

  def bank_reference_number(money_request)
    # money_request.bank_reference_number
    money_request.utr
  end

  def source_account(money_request)
    money_request.source_account
  end

  def settlement_date(money_request)
    money_request.money_request_processor_mapping&.completed_at&.strftime("%d-%m-%Y, %H:%M")
  end

  def finance_approved_date(money_request)
    money_request&.approved_at&.strftime("%d-%b-%Y")
  end

end
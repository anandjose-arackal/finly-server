class Settlement::SMoneyRequest::Processing::Init < Settlement::SMoneyRequest::Processing::Base
  attr_accessor :payment_type, :money_requests, :user_money_requests, :request_total, :user_count

  class Settlement::SMoneyRequest::Processing::Init::Success < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :details, :request_total, :user_count

    def init
      self.details = params[:details]
      self.request_total = params[:request_total]
      self.user_count = params[:user_count]
    end

  end

  def authorized_user_types
    [:admin, :finance_manager]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:money_request_id).blank? and not params&.dig(:init_all)
      add_message :error, 'MoneyRequest not found'
      return
    end
    if params&.dig(:payment_type).blank?
      add_message :error, 'Payment Type not found'
      return
    end
    if params[:payment_type] == 'payment_file'
      result = PaymentFiles::IsConfigured.(user, params)
      unless result.success?
        add_message :error, result.messages[:error]
        return
      end
    end
  end

  def init
    self.payment_type = params[:payment_type]
    init_money_requests
    return if has_errors?
    case self.payment_type
      when 'bank_transfer', 'payment_file'
        init_bank_transfer
      when 'expense_card'
        init_expense_card
      when 'outside_finly'
        init_outside_finly
    end
  end

  def validate
    if self.money_requests.blank?
      add_message :error, 'MoneyRequest not found'
      return
    end
  end

  def success
    params[:details] = self.user_money_requests
    params[:request_total] = self.request_total
    params[:user_count] = self.user_count
    Settlement::SMoneyRequest::Processing::Init::Success.new(user, params, messages)
  end

  protected
  def init_money_requests
    money_requests_presenter = ::MoneyRequest::Index.(user, params)
    unless money_requests_presenter&.success?
      message = money_requests_presenter&.messages[:error] || 'Unknown error'
      add_message :error, message
      return
    end
    self.money_requests = money_requests_presenter.money_requests.approved.include_user_accounts
    if not params&.dig(:init_all) and params&.dig(:money_request_id).present?
      self.money_requests = self.money_requests.with_id(params&.dig(:money_request_id))
    end
    user_ids = self.money_requests.pluck(:user_id).uniq
    users_map = User.with_id(user_ids).index_by(&:id)
    self.user_money_requests = []
    self.request_total = {}
    self.user_count = 0

    user_ids.each do |user_id|
      destination_pocket_ids = self.money_requests.pluck(:destination_pocket_id).uniq
      destination_pocket_ids.each do |pocket_id|
        pocket = UserPocket.find_by(id: pocket_id)
        request_ids = self.money_requests.with_user(user_id).with_destination_pocket_id(pocket_id).pluck(:id)
        amount = MoneyRequestItem.with_money_request(request_ids).sum_amount(pocket&.base_currency&.country_code)
        self.user_count += 1
        self.request_total[pocket.base_currency&.country_code] = Amount.new(value: 0, currency_id: pocket.base_currency_id) if self.request_total[pocket.base_currency&.country_code].blank?
        self.request_total[pocket.base_currency&.country_code].value += amount
        user_money_requests << {
            user: users_map[user_id],
            request_total: Amount.new(value: amount, currency_id: pocket.base_currency_id),
            money_requests: self.money_requests.with_destination_pocket_id(pocket_id).with_user(user_id),
            has_errors: false
        }
      end
    end
  end

  def init_bank_transfer
    self.user_money_requests.each do |details|
      user = details[:user]
      bank_accounts = user.bank_accounts
      details[:bank_accounts] = bank_accounts
      if bank_accounts.blank?
        details[:has_error] = true
        details[:errors] = 'User has not added a bank account'
      end
    end
  end

  def init_expense_card
    self.user_money_requests.each do |details|
      user = details[:user]
      cards = user.expense_cards
      details[:expense_cards] = cards
      if cards.blank?
        details[:has_error] = true
        details[:errors] = 'User has not been assigned a Expense Card'
        return
      end
    end
  end

  def init_outside_finly

  end

end
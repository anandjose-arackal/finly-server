# this operation simply calls the cash on hand operation that does the actual crediting
# this operation can take multiple money requests as arguments

class MoneyRequests::Cash::Credit < MoneyRequests::Base

  attr_accessor :selected_user, :money_requests, :amount, :money_request_amounts,
                :role, :payment_mode, :payment_params, :receiving_account

  def pre_validate
    super
    unless params[:money_request_ids].present?
      add_message :error, "No money requests to process"
    end
    if params[:payment][:amount].blank? or params[:payment][:amount].to_f < 0
      add_message :error, 'Amount cannot be equal to or less than 0'
      return
    end
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate this transfer'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
    end
  end

  def init
    team = User::Team::Index.(user, params)
    id = params[:id]
    self.selected_user = team.with_id(id).first rescue nil

    if selected_user.nil?
      add_message :error, "User not found"
      return
    end
    ids = params[:money_request_ids].split(',')
    self.money_requests = selected_user.money_requests.with_id(ids)
    self.payment_params = payment_parameters

    # setting the role of the creditor of the money request
    if user.admin? and admin_view?
      self.role = UserRole.id_for(:admin)
    else
      self.role = UserRole.id_for(:finance_manager)
    end

    # keeping track of the individual money requests and the respective amounts being credited to them
    self.amount = 0
    self.money_request_amounts = {}
    params[:money_requests].each do |money_request|
      self.money_request_amounts[money_request[:id]] = money_request[:processed_amount]
      self.amount += money_request[:processed_amount].to_f
    end
    # replacing the amount we're getting from the front end to the new one.
    params[:payment][:amount] = self.amount
    params.delete(:money_requests)
  end

  def authorize

  end

  def validate
    super
    money_requests.each do |money_request|
      unless money_request.approved?
        add_message :error, "Only approved money requests can be credited"
        return
      end
    end

    unless self.amount.present?
      add_message :error, "No amount passed, please try again"
      return
    end

    # validations specific to a particular validation in the money request
    if money_requests.present?

      total_amount = 0
      money_requests.each do |request|
        total_amount += request.total_amount
      end
      if self.amount&.to_f > total_amount
        add_message :error, 'You cannot credit more than the total of the money requests'
      end

      date = Date.parse(payment_params[:date])
      # validating date of money request against payment date
      if date < money_requests.order(submitted_at: :asc).first.updated_at.to_date
        add_message :error, 'Payment date cannot be before money request date'
      end
    end
  end

  def process
    # call the add cash on hand operation
    op = Settlement::Payment::AddCashAdvance.(user, params)
    if op.success?
      # i.e. the money (outside of finly, or through bank transfer)
      payment = op.payment
      ids = self.money_requests.pluck(:id)
      total_amount = MoneyRequestItem.with_money_request(ids).with_amount.sum(:value)
      selected_user.balance_sheet.subtract_pending_advance(total_amount)
      money_requests.each do |money_request|
        MoneyRequests::MarkAsCredited.(user, {payment: payment, money_request: money_request, role_id: role, amount_processed: self.money_request_amounts["#{money_request.id}"]})
      end
    else
      add_message :error, op.messages[:error]
      return
    end
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end

  private

  def payment_parameters
    params.require(:payment).permit(:note, :date, :amount)
  end

end
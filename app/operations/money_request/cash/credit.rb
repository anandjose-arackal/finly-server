# this operation simply calls the cash on hand operation that does the actual crediting
# this operation can take multiple money requests as arguments

class MoneyRequest::Cash::Credit < MoneyRequest::Base

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
    if team.success?
      id = params[:id]
      self.selected_user = team.with_id(id).first
    end
    if selected_user.nil?
      add_message :error, "User not found"
      return
    end
    ids = params[:money_request_ids].split(',')
    self.money_requests = selected_user.money_requests.with_id(ids)
    self.amount = params[:amount]

    # setting the role of the creditor of the money request
    if user.admin? and admin_view?
      self.role = UserRole.id_for(:admin)
    else
      self.role = UserRole.id_for(:finance_manager)
    end

    # keeping track of the individual money requests and the respective amounts being credited to them
    self.money_request_amounts = {}
    params[:money_requests].each do |money_request|
      self.money_request_amounts[money_request[:id]] = money_request[:processed_amount]
    end
    params.delete(:money_requests)

    self.payment_params = payment_parameters
    self.payment_mode = params[:payment_mode] # 1 - outside finly, 2 - bank transfer

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
  end

  def process
    # call the add cash on hand operation
    op = Settlement::Payment::AddCashAdvance.(user, params)
    if op.success?
      # i.e. the money (outside of finly, or through bank transfer)
    end
  end

  private

  def payment_parameters
    params.require(:payment).permit(:note, :date, :amount)
  end

end
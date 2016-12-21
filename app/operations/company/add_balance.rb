# action that sends a confirmation email to ItzCash regarding
# the balance load.
# params:
#   amount: value of balance added
#   Reference ID: the transaction ID of the NEFT transfer
#   date: Date of the NEFT transfer
#   remarks: Optional remarks
#   company_id: id of the company whose balance is being updated

class Company::AddBalance < Company::Base

  attr_accessor :transaction_details

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'Invalid input. Please try again'
    end
  end

  def authorized_user_types
    [:company_admin]
  end

  def init
    self.transaction_details = param
    self.transaction_details[:amount_attributes][:currency_id] = Currency.first.id rescue nil
  end

  def validate
    if self.transaction_details.blank?
      add_message :error, 'Nothing to update'
    end
  end

  def authorize
    unless user.company_id == params[:company_id].to_i
      raise_unauthorized_exception
    end
  end

  def process
    transaction_details[:requested_by_user_id] = self.user.id
    load_funds_request = self.user.company.fund_load_requests.build transaction_details
    unless load_funds_request.save
      add_message :error, load_funds_request.errors.full_messages
    end
  end

  def post_process
    # triggerring mailer so that itzCash is notified
    transaction_details[:company] = self.user.company.name
    CompanyMailer.delay.balance_update(transaction_details)
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end

  private
  def param
    params.permit(:reference_id, :date, :remark, :amount_attributes => [:value, :currency_id])
  end
end

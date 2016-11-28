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
      messages[:error] << "Invalid input. Please try again"
    end
  end

  def authorized_user_types
    [:company_admin]
  end

  def init
    self.transaction_details = {}
    self.transaction_details[:amount] = params[:amount]
    self.transaction_details[:reference_id] = params[:reference_id]
    self.transaction_details[:date] = params[:date]
    self.transaction_details[:remarks] = params[:remark]
    self.transaction_details[:company] = Company.find_by(id: params[:company_id]).name
  end

  def validate

  end

  def authorize
    unless user.company_id == params[:company_id].to_i
      raise_unauthorized_exception
    end
  end

  def process
    #currently we don't keep track of company balance, so nothing to do

  end

  def post_process
    # triggerring mailer so that itzCash is notified
    CompanyMailer.delay.balance_update(transaction_details)
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end
end

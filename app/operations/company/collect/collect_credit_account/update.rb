class Company::Collect::CollectCreditAccount::Update < Company::Base

  attr_accessor :credit_account, :credit_account_params

  def init
    self.credit_account = user.company.collect_credit_account
    self.credit_account_params = credit_account_parameters
  end

  def process
    if self.credit_account.blank?
      self.credit_account = user.company.build_collect_credit_account(self.credit_account_params)
    else
      self.credit_account.assign_attributes(self.credit_account_params)
    end
    unless self.credit_account.save
      add_message :error, self.credit_account.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Credit Account details updated"
  end

  private

  def credit_account_parameters
    params.require(:company).permit(:account_number, :ifsc, :name)
  end
end
class Company::LoadOptions < Company::Base

  attr_accessor :card_credits_load, :bank_credits_load

  def init
    id = params[:id] || params[:company_id]
    self.company = Company.find_by(id: id)
    self.company = user.company if self.company.blank?
  end

  def process
    self.card_credits_load = company.d_code_enabled?
    self.bank_credits_load = company.bank_reimbursement_enabled?
  end

  def success
    params[:card_credits_load] = self.card_credits_load
    params[:bank_credits_load] = self.bank_credits_load
    Company::LoadOptions::OptionsPresenter.new(user, params, messages)
  end

  class Company::LoadOptions::OptionsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :card_credits_load, :bank_credits_load

    def init
      self.card_credits_load = params[:card_credits_load]
      self.bank_credits_load = params[:bank_credits_load]
    end
  end
end
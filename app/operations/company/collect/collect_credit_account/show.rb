class Company::Collect::CollectCreditAccount::Show < Company::Base

  attr_accessor :collect_account

  class Company::Collect::CollectCreditAccount::Show::CreditAccountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :collect_account

    def init
      self.collect_account = params[:collect_account]
    end

  end

  def init
    self.collect_account = user.company.collect_credit_account
  end

  def success
    params[:collect_account] = self.collect_account
    Company::Collect::CollectCreditAccount::Show::CreditAccountPresenter.new(user, params, messages)
  end
end
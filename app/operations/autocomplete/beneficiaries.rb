class Autocomplete::Beneficiaries < BaseOperation

  attr_accessor :beneficiaries

  def init
    params[:filter_search] = params[:filter_search].strip if params[:filter_search].present?
  end

  def process
    op = BankTransfer::BankAccounts::Index.(user, params)
    if op.success?
      self.beneficiaries = op.bank_accounts
    end
  end

  def success
    params[:beneficiaries] = self.beneficiaries
  end

  class Autocomplete::Beneficiaries::BeneficiariesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :beneficiaries

    def init
      self.beneficiaries = params[:beneficiaries]
    end

  end
end
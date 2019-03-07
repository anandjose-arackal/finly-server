class RateContracts::Show < RateContracts::Base
  attr_accessor :rate_contract

  def init
    rate_contracts_presenter = RateContracts::Index.(user, params)
    unless rate_contracts_presenter.success?
      add_message :error, "No rate contract found"
      return
    end
    id = params[:id] or params[:rate_contract_id]
    self.rate_contract = RateContract.find_by_id(id)
  end

  def validate
    unless rate_contract.present?
      add_message :error, "Rate Contract not found"
      return
    end
  end

  def success
    params[:rate_contract] = self.rate_contract
    RateContracts::Show::RateContractsPresenter.new(user, params, messages)
  end

  # Presenter
  class RateContracts::Show::RateContractsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :rate_contract, :rate_contract_line_items

    def init
      self.rate_contract = params[:rate_contract]
      self.rate_contract_line_items = rate_contract.rate_contract_line_items if rate_contract.present?
    end
  end

end
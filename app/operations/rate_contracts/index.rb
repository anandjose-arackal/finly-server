class RateContracts::Index < RateContracts::Base

  attr_accessor :rate_contracts


  def process
    self.rate_contracts = RateContract.includes(:rate_contract_line_items)
  end

  def success
    params[:rate_contracts] = rate_contracts
    RateContracts::Index::IndexPresenter.new(user, params, messages)
  end

  # Presenter
  class RateContracts::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :rate_contracts, :count, :paginated_rate_contracts
    def init  
      self.rate_contracts = params[:rate_contracts]
      self.count = rate_contracts.count
      self.paginated_rate_contracts = rate_contracts.paginate(page: params[:page], per_page: 30) rescue nil
    end
  end
end
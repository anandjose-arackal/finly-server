class RateContracts::Create < RateContracts::Base

  attr_accessor :rate_contract, :params

  def init
    self.params[:rate_contract][:creator_id] = user.id
  end

  def validate
    if params[:rate_contract][:name].blank?
      add_message :error, "Contract name can't be blank"
      return
    end
  end

  def process
    rate_contract = RateContract.new(strong_params)
    unless  rate_contract.save
      add_message :error, rate_contract.errors.full_messages
      return
    end
    self.rate_contract = rate_contract
  end

  def post_process
    add_message :success, 'Rate Contract Added'
  end

  def success
    RateContracts::Create::CreatePresenter.new(user, {rate_contract: rate_contract}, messages)
  end

  # Presenter Start
  class RateContracts::Create::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :id, :name, :rate_contract

    def init
      self.rate_contract = params[:rate_contract]
      self.id = rate_contract.id
      self.name = rate_contract.name
      self.rate_contract = rate_contract
    end
  end
  
end
class RateContracts::Update < RateContracts::Base

  attr_accessor :rate_contract

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    id = params[:id] or params[:rate_contract_id]
    self.rate_contract = RateContract.find_by_id(id) if id
  end

  def validate
    super
     unless rate_contract.present?
      add_message :error, 'Unable to find rate contract'
     end
  end

  def process
    # Update RateContract
    if self.rate_contract.present?
      add_message :error, rate_contract.errors.full_messages unless rate_contract.update_attributes(strong_params)
    end
  end

  def post_process
    add_message :success, 'Rate Contracts successfully updated'
  end
end
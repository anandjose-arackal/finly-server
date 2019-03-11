class RateContracts::Destroy < RateContracts::Base
  attr_accessor :rate_contract

  def init
    id = params[:id] || params[:rate_contract_id]
    self.rate_contract = RateContract.find_by_id(id)
  end

  def authorize
    unless rate_contract.present? && rate_contract.creator_id == user.id
      raise_unauthorized_exception
      return
    end    
  end

  def process
    unless self.rate_contract.destroy
      add_message :error, "Some error occurred, unable to delete!"
      return
    end
  end

  def post_process
    add_message :success, 'Rate contract deleted!'
  end
end
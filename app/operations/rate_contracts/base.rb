class RateContracts::Base < BaseOperation
  attr_accessor :rate_contract, :company

  def authorized_user_types
    [:employee]
  end

  def init
    id = params[:id] || params[:rate_contract_id]
    self.rate_contract = RateContract.find_by_id(id)
    self.company = user.company
  end


  def pre_validate
    unless user.present? && params.present?
      add_message :error, 'Invalid Request'
    end
  end

  protected
  # Params whitelisting
  def strong_params
    params.require(:rate_contract).permit(:name, :vendor_id, :renewal_alert, :creator_id, rate_contract_line_items_attributes: [:id, :location_id, :item_id, :start_date, :end_date, :amount, :_destroy], artifacts_attributes: [:id, :attachment, :description, :_destroy])
  end 
end
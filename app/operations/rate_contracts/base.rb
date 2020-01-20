class RateContracts::Base < BaseOperation
  attr_accessor :rate_contract, :company, :custom_fields

  def authorized_user_types
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

  def validate_custom_fields(save = false)
    set_fields = set_custom_fields self.rate_contract, self.custom_fields, save
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    valid = CustomField::Validate.(self.rate_contract)
    unless valid.success?
      add_message :error, valid.messages[:error]
      return
    end
  end

  def set_custom_fields(rate_contract, data, save)
    custom_fields = {custom_fields: data}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(rate_contract, FieldParentType.id_for(:rate_contract), custom_fields)
  end

  protected
  # Params whitelisting
  def strong_params
    params.require(:rate_contract).permit(:name, :vendor_id, :renewal_alert_number, :renewal_alert_period_id, :item_id,
                                         :renewable, :note, :creator_id,
                                          rate_contract_line_items_attributes: [
                                              :id, :location_id, :item_id, :start_date, :end_date, :amount, :_destroy,
                                              artifacts_attributes: [:id, :attachment, :_destroy],
                                              amount_attributes: [:currency_id, :value, :_destroy, :id]
                                          ],
                                          artifacts_attributes: [:id, :attachment, :_destroy])
  end 
end
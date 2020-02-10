class Procurements::PurchaseRequests::Base < BaseOperation
  attr_accessor :workflow_output, :company, :purchase_request, :purchase_request_item


  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
  end

  def init
    self.company = user.company
    result = Procurements::PurchaseRequests::Show.(current_user, params)

    unless result.success?
      add_message :error, result.messages[:error]
      return
    end

    self.purchase_request = result.purchase_request
  end

  def validate
    if purchase_request.blank?
      add_message :error, 'Purchase request not found'
    end
  end

  def purchase_request_parameters
    params.require(:purchase_request).permit(
      :id, :location_id, :department_id, :cost_center_id, :note, :description, :reject_note , :cost_allocation_items,
        :policy_id,
        custom_fields: [],
        purchase_request_items_attributes: [
            :id, :department_id, :cost_center_id , :unit_of_measurement, :item_id, :reject_note, :required_by_date, :purpose, :category_id, :delivery_location_id, :hsn_sac, :quantity, :vendor_id, :rate_contract_item_id, :_destroy, per_unit_estimated_amount_attributes: [:id, :value, :currency_id, :_destroy, :rejected]
        ],
        attachment_attributes: [
          :id, :resource_id, :resource_type, :file_file_name, :file_file_size, :file_content_type, :file_updated_at, :description]
    )
  end

  def validate_custom_fields_pr
    set_fields = set_custom_fields_pr self.purchase_request, self.custom_fields, false
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    valid = CustomField::Validate.(self.purchase_request)
    unless valid.success?
      add_message :error, valid.messages[:error]
      return
    end
  end

  def set_custom_fields_pr(purchase_request, data, save)
    custom_fields = {custom_fields: data}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(purchase_request, FieldParentType.id_for(:purchase_request), custom_fields)
  end

end
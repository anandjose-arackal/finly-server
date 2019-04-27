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
    self.purchase_request = Procurements::PurchaseRequests::Show.(current_user, params).purchase_request
  end

  def validate
    if purchase_request.blank?
      add_message :error, 'Purchase request not found'
    end
  end

  def purchase_request_parameters
    params.require(:purchase_request).permit(
      :id, :location_id, :department_id, :cost_center_id, :note, :description, :reject_note,
        :policy_id,
        purchase_request_items_attributes: [
            :id, :department_id, :cost_center_id , :unit_of_measurement, :item_id, :reject_note, :required_by_date, :purpose, :delivery_location_id, :quantity, :vendor_id, :_destroy, per_unit_estimated_amount_attributes: [:id, :value, :currency_id, :_destroy, :rejected, attachment_attributes: [
          :id, :resource_id, :resource_type, :file_file_name, :file_file_size, :file_content_type, :file_updated_at, :description]]
        ],
        attachment_attributes: [
          :id, :resource_id, :resource_type, :file_file_name, :file_file_size, :file_content_type, :file_updated_at, :description]
    )
  end

end
class Procurements::PurchaseRequests::Base < BaseOperation
  attr_accessor :workflow_output
  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
  end

  def purchase_request_parameters
    params.require(:purchase_request).permit(
      :id, :location_id, :vendor_id, :sub_department_id, :note, :title,
        :policy_id, :department_id,        
        line_items_attributes: [
            :id, :delivery_date, :purpose, :delivery_location_id, :quantity, :unit_type, unit_amount: [:id, :value, :currency_id], inventory_line_item: [:id, :name],
            vendor: [:id, :name], estimated_amount: [:id, :value, :currency_id]
        ]
    )
  end
end
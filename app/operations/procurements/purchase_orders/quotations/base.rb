class Procurements::PurchaseOrders::Quotations::Base < BaseOperation
  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
  end

  def quotation_parameters
    params.require(:quotation).permit(
        :id, :purchase_order_id, :vendor_name, :vendor_location, :estimated_delivery_time, :total_amount, :advance_amount, :credit_period, :note, :selected, attachments: []
    )
    # params.require(:quotations).map do |q|
    #   q.permit(:id, :vendor_name, :vendor_location, :estimated_delivery_time, :total_amount, :advance_amount, :credit_period, :note, :selected, attachments: [])
    # end
  end
end

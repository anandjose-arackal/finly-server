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

    )
  end
end
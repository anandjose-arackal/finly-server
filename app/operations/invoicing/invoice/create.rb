class Invoicing::Invoice::Create < Invoicing::Invoice::Base

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    id = params[:id] || params[:payment_id]
    self.payment = Payment.find_by(id: id)
  end

end
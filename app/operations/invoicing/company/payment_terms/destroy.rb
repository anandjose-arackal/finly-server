class Invoicing::Company::PaymentTerms::Destroy < Invoicing::Company::PaymentTerms::Base

  attr_accessor :payment_term
  
  def init
    id = params[:id] || params[:payment_term_id]
    self.payment_term = user.company.payment_terms.find_by(id: id)
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.payment_term.blank?
      add_message :error, "Payment term not found"
      return
    end

    if self.payment_term.default
      add_message :error, "Cannot delete default payment term"
      return
    end
  end

  def process
    unless self.payment_term.destroy
      add_message :error, self.payment_term.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Payment terms destroyed"
  end
end
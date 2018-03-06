class Invoicing::Company::PaymentTerms::Update < Invoicing::Company::PaymentTerms::Base

  attr_accessor :payment_term, :payment_term_parameters

  def init
    id = params[:id] || params[:payment_term_id]
    self.payment_term = user.company.payment_terms.find_by(id: id)
    self.payment_term_parameters = payment_term_params
  end

  def validate
    if self.payment_term.blank?
      add_message :error, "Payment term not found"
      return
    end
  end

  def process
    unless self.payment_term.update(payment_term_parameters)
      add_message :error, self.payment_term.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Payment terms updated"
  end
end
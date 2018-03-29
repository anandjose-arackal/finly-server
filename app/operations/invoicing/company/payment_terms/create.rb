class Invoicing::Company::PaymentTerms::Create < Invoicing::Company::PaymentTerms::Base

  attr_accessor :payment_term, :payment_term_parameters

  def init
    self.payment_term_parameters = payment_term_params
  end

  def process
    self.payment_term = user.company.payment_terms.build(self.payment_term_parameters)
    unless self.payment_term.save
      add_message :error, self.payment_term.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Payment Term created!"
  end
end

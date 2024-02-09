class Invoicing::Company::PaymentTerms::Create < Invoicing::Company::PaymentTerms::Base

  attr_accessor :payment_term, :payment_term_parameters, :set_default_payment_term

  def init
    self.payment_term_parameters = payment_term_params
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def pre_process
    if payment_term_parameters[:default] == '1'
      self.set_default_payment_term = true
    end

  end

  def validate
    if self.payment_term_parameters[:days_after]&.to_i < 0
      add_message :error, 'Days After should not be negative'
    end
  end

  def process
    self.payment_term = user.company.payment_terms.build(self.payment_term_parameters)
    if payment_term.valid?
      if set_default_payment_term
        user.company.payment_terms.update_all(default: false)
      end
    end
    unless self.payment_term.save
      add_message :error, self.payment_term.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Payment Term created!"
  end
end

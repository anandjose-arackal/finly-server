class Invoicing::Company::PaymentTerms::Update < Invoicing::Company::PaymentTerms::Base

  attr_accessor :payment_term, :payment_term_parameters, :set_default_payment_term

  def init
    id = params[:id] || params[:payment_term_id]
    self.payment_term = user.company.payment_terms.find_by(id: id)
    self.payment_term_parameters = payment_term_params
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.payment_term.blank?
      add_message :error, "Payment term not found"
      return
    end
  end

  def pre_process
    self.set_default_payment_term = false
    if !payment_term.default && payment_term_parameters[:default] == '1'
      self.set_default_payment_term = true
    end

    if payment_term_parameters[:default] == '1'
      payment_term_parameters[:default] = true
    else
      payment_term_parameters[:default] = false
    end

  end

  def process
    self.payment_term.assign_attributes(payment_term_parameters)
    if payment_term.valid?
      if set_default_payment_term
        user.company.payment_terms.update_all(default: false)
      end

      payment_term.save
    else
      add_message :error, self.payment_term.errors.full_messages
    end

  end

  def post_process
    add_message :success, "Payment terms updated"
  end
end
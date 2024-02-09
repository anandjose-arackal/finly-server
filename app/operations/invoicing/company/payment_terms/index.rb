class Invoicing::Company::PaymentTerms::Index < Invoicing::Company::PaymentTerms::Base

  attr_accessor :payment_terms

  class Invoicing::Company::PaymentTerms::Index::PaymentTermsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payment_terms

    def init
      self.payment_terms = params[:payment_terms]
    end

  end

  def init
    self.payment_terms = user.company.payment_terms
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def success
    params[:payment_terms] = self.payment_terms
    Invoicing::Company::PaymentTerms::Index::PaymentTermsPresenter.new(user, params, messages)
  end
end
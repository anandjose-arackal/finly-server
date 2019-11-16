class PaymentAgreements::DocumentConfig < PaymentAgreements::Base

  attr_accessor :payment_agreement

  class PaymentAgreements::DocumentConfig::DocumentConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :policies, :payment_agreement, :payment_agreement_types, :tax_rates, :payment_terms, :billing_types, :period, :gst_types, :bank_payment_request_policies, :custom_fields_config

    def init
      self.payment_agreement = params[:payment_agreement]
      params[:filter_role_id] = [UserRole.id_for(:payment_agreement_initiator)]
      initiating_user = self.payment_agreement.present? ? payment_agreement.creator : user
      self.policies = Policy::VendorPayments::Index.(initiating_user, params).policies
      self.payment_agreement_types = ::PaymentAgreement::AGREEMENT_TYPES
      self.tax_rates = user.company.tax_rates
      self.payment_terms = user.company.payment_terms.where.not(days_after: nil)
      self.billing_types = BillingType.all
      self.period = Period.where(name: 'month')
      self.gst_types = GstType.all
      params[:filter_role_id] = [UserRole.id_for(:bank_payment_request_initiator)]
      self.bank_payment_request_policies = Policy::VendorPayments::Index.(initiating_user, params).policies
      # params[:field_parent_type_id] = FieldParentType.id_for(:invoice)
      custom_field_configurations
    end

    def custom_field_configurations
      configurations = user.company.field_configurations.exclude_deleted.root_fields.order_created_at_desc
      self.custom_fields_config = {}
      self.custom_fields_config[:general_invoice] = configurations.with_parent_type(FieldParentType.id_for(:general_invoice))
      self.custom_fields_config[:rental_invoice] = configurations.with_parent_type(FieldParentType.id_for(:rental_invoice))
      self.custom_fields_config[:payment_agreement] = configurations.with_parent_type(FieldParentType.id_for(:payment_agreement))
    end
  end

  def init
    self.payment_agreement = PaymentAgreements::Show.(user, params).payment_agreement rescue nil
  end


  def success
    params[:payment_agreement] = self.payment_agreement
    PaymentAgreements::DocumentConfig::DocumentConfigPresenter.new(user, params, messages)
  end

end
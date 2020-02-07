class PaymentAgreements::EditableFields < PaymentAgreements::Base

  attr_accessor :payment_agreement, :payment_agreement_editable_fields, :general_invoice_editable_fields, :rental_invoice_editable_fields, :security_deposit_editable_fields, :beneficiary_payment_editable_fields
  def init
    id = params[:id] || params[:payment_agreement_id]
    self.payment_agreement = user.company.payment_agreements.find_by_id id
  end

  def process
    self.payment_agreement_editable_fields = payment_agreement_field_config
    self.general_invoice_editable_fields = general_invoice_field_config
    self.rental_invoice_editable_fields = rental_invoice_field_config
    self.security_deposit_editable_fields = security_deposit_field_config
    self.beneficiary_payment_editable_fields = beneficiary_payment_field_config
  end

  def success
    params[:payment_agreement_editable_fields] = self.payment_agreement_editable_fields
    params[:general_invoice_editable_fields] = self.general_invoice_editable_fields
    params[:rental_invoice_editable_fields] = self.rental_invoice_editable_fields
    params[:security_deposit_editable_fields] = self.security_deposit_editable_fields
    params[:beneficiary_payment_editable_fields] = self.beneficiary_payment_editable_fields
    PaymentAgreements::EditableFields::EditableFieldsPresenter.new(user, params, messages)    
  end

  class PaymentAgreements::EditableFields::EditableFieldsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payment_agreement_editable_fields, :general_invoice_editable_fields, :rental_invoice_editable_fields, :security_deposit_editable_fields, :beneficiary_payment_editable_fields

    def init
      self.payment_agreement_editable_fields = params[:payment_agreement_editable_fields]
      self.general_invoice_editable_fields = params[:general_invoice_editable_fields]
      self.rental_invoice_editable_fields = params[:rental_invoice_editable_fields]
      self.security_deposit_editable_fields = params[:security_deposit_editable_fields]
      self.beneficiary_payment_editable_fields = params[:beneficiary_payment_editable_fields]
    end
  end

  def payment_agreement_field_config
    {
      agreement_number: true,
      title: true,
      policy: true,
      agreement_date: true,
      execution_date: true,
      expiration_date: true,
      no_expiration: true,
      renewal_date: true,
      renewal_reminder: true,
      note: true
    }
  end


  def general_invoice_field_config
    # return {} if self.payment_agreement.general_invoices.blank?
    invoice_field_config
  end

  def rental_invoice_field_config
    # return {} if self.payment_agreement.rental_invoices.blank?
    field_config = {
      lock_in_perioid: true,
      rent_free_period: true,
      tenancy_period: true,
      notice_period: true,
      square_feet: true
    }
    invoice_field_config.merge(field_config)
  end

  def invoice_field_config
    {
      serial_number: true,
      vendor_name: true,
      vendor_location: true,
      start_date: true,
      end_date: true,
      account_name: true,
      department: true,
      location: true,
      cost_center: true,
      payment_term: true,
      due_date: true,
      billing_type: true,
      note: true,
      concerned_person: true,
      tds: true,
      line_items: {
        description: true,
        comment: true,
        quantity: true,
        unit_of_measurement: true,
        expected_rate: true,
        discount: true,
        tax_rate: true
      }
    }
  end

  def security_deposit_field_config
    # return {} if self.payment_agreement.security_deposits.blank?
    {
      vendor_name: true,
      vendor_location: true,
      account_name: true,
      cost_center: true,
      department: true,
      location: true,
      note: true,
      amount: true
    }
  end

  def beneficiary_payment_field_config
    # return {} if self.payment_agreement.beneficiary_payments.blank?
    {
      vendor_name: true,
      vendor_location: true,
      account_name: true,
      cost_center: true,
      department: true,
      location: true,
      note: true,
      inclusive_of_taxes: true,
      amount: true,
      tax_type: true,
      tax_percent: true,
      tds_percentage: true,

    }
  end
end
class PaymentAgreements::Update < PaymentAgreements::Base
  attr_accessor :payment_agreement, :payment_agreement_params

  def init
    super
    self.payment_agreement_params = payment_agreement_parameters
    self.payment_agreement = user.company.payment_agreements.find_by_id(params[:id])

  end

  def process
    self.payment_agreement.assign_attributes(payment_agreement_parameters)
    if payment_agreement.valid?
      # Set validation of DLRMs
      if PaymentAgreement.status_ids(:open, :retracted, :rejected).include?(payment_agreement.status_id) && purchase_order.creator_id == user.id

        dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::ValidationUpdate.(user, {
          reviewal_document: self.payment_agreement,
          document_reviewer_mappings_params: document_reviewer_mappings_params
        })

        unless dlrm_validation_op.success?
          add_message :error, dlrm_validation_op.messages[:error]
          return
        end
      end
    end


    if self.payment_agreement.save
      update_amount_attributes
      params[:reviewal_document] = self.payment_agreement
      document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
      unless document_reviewer_mappings_op.success?
        add_message :error, document_reviewer_mappings_op.messages[:error]
      end
      return
    else
      add_message :error, payment_agreement.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, 'Successfully updated agreements'
  end

  def success
    params[:payment_agreement] = self.payment_agreement
    PaymentAgreements::Update::UpdatePresenter.new(user, params, messages)
  end

  class PaymentAgreements::Update::UpdatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_agreement

    def init
      self.payment_agreement = params[:payment_agreement]
    end
  end

  private
  def update_amount_attributes
    if payment_agreement.general_invoices.present?
      payment_agreement.general_invoices.map{|i| i.items.map(&:update_taxable_amount_value)}
      payment_agreement.general_invoices.map{|i| i.items.map(&:update_net_amount_value)}
      payment_agreement.general_invoices.map{|i| i.items.map(&:update_tax_amount_value)}
      payment_agreement.general_invoices.map(&:update_net_amount_value)
    end

    if payment_agreement.rental_invoices.present?
      payment_agreement.rental_invoices.map{|i| i.items.map(&:update_taxable_amount_value)}
      payment_agreement.rental_invoices.map{|i| i.items.map(&:update_net_amount_value)}
      payment_agreement.rental_invoices.map{|i| i.items.map(&:update_tax_amount_value)}
      payment_agreement.rental_invoices.map(&:update_net_amount_value)
    end

    # if payment_agreement.beneficiary_payments.present?
    #   payment_agreement.beneficiary_payments
    # end

    # if payment_agreement.security_deposits.present?
    #   payment_agreement.security_deposits
    # end
  end

end
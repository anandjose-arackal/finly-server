class PaymentAgreements::Update < PaymentAgreements::Base
  attr_accessor :payment_agreement, :payment_agreement_params, :document_reviewer_mappings_params, :custom_fields

  def init
    super
    self.payment_agreement_params = payment_agreement_parameters
    self.payment_agreement = user.company.payment_agreements.find_by_id(params[:id])
    self.document_reviewer_mappings_params = params[:document_reviewer_mappings]
    self.custom_fields = params&.dig(:custom_fields) || params&.dig(:invoice, :custom_fields)
  end
  def pre_validate
    existing_users = self.payment_agreement&.notify_users&.pluck(:user_id)
    return if existing_users.blank?
    payment_agreement_params[:payment_agreement][:notify_users_attributes].reject!{|h| (existing_users.include?(h[:user_id]) && h[:_destroy] != true)}
  end

  def validate
    self.payment_agreement.assign_attributes(payment_agreement_params)
    if self.payment_agreement.general_invoices.present?
      self.payment_agreement.general_invoices.each do |general_invoice|
        general_invoice.set_creator_and_company(user)
        update_invoice_limit(general_invoice)
      end
    end
    if self.payment_agreement.rental_invoices.present?
      self.payment_agreement.rental_invoices.each do |rental_invoice| 
        rental_invoice.set_creator_and_company(user)
      end
    end
    validate_item_quantity
    ActiveRecord::Base.transaction(requires_new: true) do
      if self.payment_agreement.save
        validate_invoice_line_items unless has_errors?
        validate_prepaid_consistency unless has_errors? 
        security_deposit_validation unless has_errors?
        validate_invoice_frequency unless has_errors?
        validate_invoice_start_end_date unless has_errors?
        fixed_periodic_grouped_vendor_validations unless has_errors?
        check_agreement_item_presence unless has_errors?
        billing_type_validations unless has_errors?
        validate_agreement_item_combinations unless has_errors?
        create_or_update_custom_fields
        if has_errors?
          raise ActiveRecord::Rollback
          return
        end
      end
    end
  end

  def process
    clear_expiration_date_on_no_expiration
    ActiveRecord::Base.transaction(requires_new: true) do
      return if has_errors?
      if self.payment_agreement.general_invoices.present?
        self.payment_agreement.general_invoices.each do |general_invoice|
          general_invoice.set_creator_and_company(user)
          update_invoice_limit(general_invoice)
        end
      end
      if self.payment_agreement.rental_invoices.present?
        self.payment_agreement.rental_invoices.each do |rental_invoice|
         rental_invoice.set_creator_and_company(user)
        end
      end
      if payment_agreement.valid?
        # Set validation of DLRMs
        if PaymentAgreement.status_ids(:draft, :retracted, :rejected).include?(payment_agreement.status_id) && payment_agreement.creator_id == user.id
          if payment_agreement.dlrms.present?
            dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::Validate.(user, {
                reviewal_document: self.payment_agreement,
                document_reviewer_mappings_params: document_reviewer_mappings_params
            })
            unless dlrm_validation_op.success?
              add_message :error, dlrm_validation_op.messages[:error]
              raise ActiveRecord::Rollback
              return
            end
          end
        end
      end

      if self.payment_agreement.save && self.payment_agreement.reload
        update_item_attributes

        # Set total amount on agreement level
        update_total_amount
        params[:reviewal_document] = self.payment_agreement.reload
        params[:document_reviewer_mappings] = document_reviewer_mappings_params
        if PaymentAgreement.status_ids(:draft, :retracted, :rejected).include?(payment_agreement.status_id) && payment_agreement.creator_id == user.id
          document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
          unless document_reviewer_mappings_op.success?
            add_message :error, document_reviewer_mappings_op.messages[:error]
            raise ActiveRecord::Rollback
            return
          end
        end
      else
        add_message :error, payment_agreement.errors.full_messages
        raise ActiveRecord::Rollback
        return
      end
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


end
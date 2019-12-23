class Docs::P2P::CreditNotes::Ops::Create < Transactions::API

  schema do
    params do
      required(:credit_note) do
        hash do
          required(:invoice_id).filled
        end
      end
    end
  end

  # Create an empty model
  step Model(CreditNote, :new)

  step :init

  # Prevalidation
  step :pre_validate

  # Validate
  step :validate

  # Pass the model to the policy and check if user can perform the action
  step Policy::Pundit(Docs::P2P::CreditNotes::Authorizer, :create?)

  # Below method makes sure all necessary data is present for contract to work properly, it also sets default value for
  # number of attributes
  step :set_default_params

  # Instantiate contract
  step Contract::Build(constant: Docs::P2P::CreditNotes::Contracts::Create)

  # Validate Contract; 'key' represents under which key in params all the data can be found so it can be assigned to the
  # contract and data can be validated
  step Contract::Validate(key: 'credit_note')


  # Persist saves the model if validations go through successfully
  step Contract::Persist()

  # Creates DLRMs post creation of document
  step :setup_dlrm

  step Transactions::Messages::SuccessMessage('Successfully Added Credit Note')


  def init(options, current_user:, params:, **)
    invoice_id = params[:credit_note][:invoice_id]

    invoice = Procurements::Invoices::Show.(current_user, {id: invoice_id}).invoice rescue nil
    options[:invoice] = invoice
    true
  end

  def pre_validate(options, current_user:, **)
    # Validate Invoice Presence
    unless options[:invoice].present?
      add_message(options, :error, :invoice, "Unable to load Invoice")
      return
    end
    true
  end

  def validate(options, current_user:, invoice:, **)
    if invoice.credit_note.present?
      credit_note = invoice.credit_note
      add_message(options, :error, :invoice_id, "Credit Note with sequence id #{credit_note.sequence_id} already exists for the invoice")
      return
    end

    true
  end

  def setup_dlrm(options, current_user:, params:, model:, **)
    dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::Set.(current_user, {
        reviewal_document: model,
        document_reviewer_mappings: params[:document_reviewer_mappings]
    })
    dlrm_validation_op.success?
    true
  end

  def set_default_params(options, params:, current_user:, invoice:, **)
    # Credit Note Attributes
    params[:credit_note][:user_id] = current_user&.id
    params[:credit_note][:company_id] = current_user&.company_id
    params[:credit_note][:current_user] = current_user

    params[:credit_note][:invoice_id] = invoice.id
    params[:credit_note][:procurement_id] = invoice.procurement&.id
    params[:credit_note][:tds_rate_id] = invoice.tds_slab_id
    params[:credit_note][:department_id] = invoice.department_id
    params[:credit_note][:cost_center_id] = invoice.cost_center_id
    params[:credit_note][:shipping_location_id] = invoice.delivery_location_id
    params[:credit_note][:billing_location_id] = invoice.location_id
    params[:credit_note][:vendor_id] = invoice.vendor_id
    params[:credit_note][:billing_address] = invoice.billing_address
    params[:credit_note][:shipping_address] = invoice.shipping_address

    # Credit Note Items Attributes
    items = []
    invoice.items.each do |item|
      if item.discount_amount.present? && item.discount_amount.value > 0
        discount_amount = item.discount_amount.value / item.quantity
        rate = item.rate - discount_amount
      else
        rate = item.rate
      end
      item_attr = {
          item_id: item.inventory_line_item_id,
          invoice_item_id: item.id,
          category_id: item.category_id,
          comment: item.description,
          hsn_sac: item.hsn_sac,
          original_quantity: item.quantity,
          quantity: item.quantity,
          original_rate: rate,
          rate: rate,
          original_taxable_amount: {
              value: item.taxable_amount.value,
              currency_id: item.taxable_amount.currency_id
          },
          taxable_amount: {
              value: item.taxable_amount.value,
              currency_id: item.taxable_amount.currency_id
          },
          original_tax_rate_id: item.tax_rate_id,
          tax_rate_id: item.tax_rate_id
      }
      items.push(item_attr)
    end
    params[:credit_note][:items] = items

    true
  end
end


# Logics
# 1. If invoice already has a credit note
# 2. By Default calculate revised rate as inclusive of discount
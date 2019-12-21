class Docs::P2P::CreditNotes::Ops::Create < Transactions::API

  # Create an empty model
  step Model(CreditNote, :new)

  # Pass the model to the policy and check if user can perform the action
  step Policy::Pundit(Docs::P2P::CreditNotes::Authorizer, :create?)

  # Since most of details will be picked from invoice, invoice has to be set
  step :get_invoice

  # Below method makes sure all necessary data is present for contract to work properly, it also sets default value for
  # number of attributes
  step :set_default_params

  # Instantiate contract
  step Contract::Build(constant: Docs::P2P::CreditNotes::Contracts::Create)

  # Validate Contract; 'key' represents under which key in params all the data can be found so it can be assigned to the
  # contract and data can be validated
  step Contract::Validate(key: 'credit_note')

  # Just a methoid to for testing; will be removed in future
  # step :check
  # fail :check

  # Persist saves the model if validations go through successfully
  step Contract::Persist()

  # Creates DLRMs post creation of document
  step :setup_dlrm

  step Transactions::Messages::SuccessMessage('Successfully Added Credit Note')

  def check(params, **)
    true
  end

  def get_invoice(options, current_user:, params:, **)
    invoice_id = params[:credit_note][:invoice_id]
    if invoice_id.blank?
      add_message(options, :error, :invoice_id, "Invoice not found")
      return false
    end

    invoice_show_op = Procurements::Invoices::Show.(current_user, {id: invoice_id})
    unless invoice_show_op.success?
      add_message(options, :error, :invoice_id, "Unable to load Invoice")
      return false
    end

    options[:invoice] = invoice_show_op.invoice
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
      item_attr = {
          item_id: item.inventory_line_item_id,
          invoice_item_id: item.id,
          category_id: item.category_id,
          comment: item.description,
          hsn_sac: item.hsn_sac,
          original_quantity: item.quantity,
          quantity: item.quantity,
          original_rate: item.rate,
          rate: item.rate,
          original_taxable_amount: {
              value: item.taxable_amount.value,
              currency_id: item.taxable_amount.currency_id
          },
          taxable_amount: {
              value: item.taxable_amount.value,
              currency_id: item.taxable_amount.currency_id
          },
          # original_taxable_amount: Amount.new({
          #     value: item.taxable_amount.value,
          #     currency_id: item.taxable_amount.currency_id
          # }),
          # taxable_amount: Amount.new({
          #     value: item.taxable_amount.value,
          #     currency_id: item.taxable_amount.currency_id
          # }),
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
# called when user adds excel sheet or manually adds new payments
# This would create multiple individual payments for payment ticket/bankpaymentrequest in the background

class BankTransfer::PaymentRequest::Beneficiary::BeneficiaryPaymentsBackground < BackgroundOperation
  sidekiq_options queue: :payments_queue

  attr_accessor :bank_payment_request, :payments_attributes, :payment_mode, :options,
                :company_id, :execute, :payment_params, :beneficiary_payments, :from_payment_agreement, :agreement_type, :agreement_related_document_id, :ticket_type, :security_deposit, :beneficiary_payment, :security_deposits, :agreement_beneficiary_payment, :agreement_security_deposit, 
                :init_text_field, :init_drop_down_field, :import_id, :import_number, :import_date, :init_multi_select_field, :init_multi_select_selction_items, :transfer_mode_id, :tax_rate_id, :logger, :log_data

  def self.call(user, options = {})
    self.new.perform(user, options)
  end

  def perform(user, options, request_store_hash = nil)
    self.logger = LogStashLogger.new(type: :file, path: 'log/logstash_payments_creation.log', sync: true)
    self.log_data = {}
    self.log_data[:start_time] = DateTime.now.utc
    self.log_data[:klass_name] = self.class.name
    self.log_data[:job] = "payments_creation"
    load_request_store request_store_hash
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.bank_payment_request = BankPaymentRequest.find_by(id: options[:bank_payment_request_id])
    self.log_data[:bank_payment_request_id] = self.bank_payment_request&.id
    self.payments_attributes = options[:payments_attributes]
    self.log_data[:number_of_payments] = self.payments_attributes.count
    self.from_payment_agreement = options[:created_from_payment_agreement]
    # Payment agreement type
    self.agreement_type = options[:agreement_type]
    # For payment agreement type id
    self.agreement_related_document_id = options[:document_id]
    self.ticket_type = options[:ticket_type]
    self.options = options
    self.run
  end

  def initialize

  end

  def pre_validate
    if self.bank_payment_request.blank?
      add_message :error, "Payment order not found"
    end
  end

  def init
    company = self.bank_payment_request.owner.company.name.split.first.parameterize.to_s
    date = DateTime.now.strftime('%b-%d-%a-%H-%M-%S').downcase
    rnd = SecureRandom.hex(11)
    self.import_id = (company + "-" + date + "-" + rnd).freeze
    self.import_number = rand(100_000_000..999_999_999)
    self.import_date = DateTime.now + rand(2..11).years

    self.company_id = self.bank_payment_request.owner.company_id
    self.log_data[:company_name] = self.bank_payment_request.owner.company.name
    self.log_data[:company_id] = self.company_id
    self.user = self.bank_payment_request.owner
    self.payment_mode = self.bank_payment_request.payment_mode
    self.transfer_mode_id = self.bank_payment_request.transfer_mode_id
    # here assign attributes to the existing bank payment request object which can be saved later
    self.payment_params = []
    initiating_account = retrieve_initiating_account(user.company)
    self.payments_attributes.each do |payment|
      bank_account = retrieve_bank_account(payment)
      payment[:advance_amount] = (payment[:advance_amount].blank?) ? 0 : payment[:advance_amount]
      if from_payment_agreement
        document = find_agreement_related_document
        if document.present? 
          case
          when document.is_a?(BeneficiaryPayment)
            self.agreement_beneficiary_payment = document
          when document.is_a?(SecurityDeposit)
            self.agreement_security_deposit = document
          end
        end
      end

      # self.beneficiary_payment = from_payment_agreement ? agreement_beneficiary_payment : retrieve_beneficiary_payment(payment, bank_account)

      # Do not call this when agreement type is security deposit
      # Cannot puts params based conditions as not sure what params and places are affecting this action
      if agreement_security_deposit.blank?
        self.beneficiary_payment = retrieve_beneficiary_payment(payment, bank_account)
      end

      if agreement_security_deposit.present?
        self.security_deposit = agreement_security_deposit
      end

      payment[:date] = payment[:invoice_date] || payment[:date]
      payment[:due_date] = payment[:invoice_due_date] || payment[:due_date]
      self.payment_params << {
          payment_type_id: PaymentType.id_for(:credit),
          application: "vp",
          receiving_user_type: bank_account.account_owner.class.name,
          receiving_user_id: bank_account.account_owner_id,
          initiating_user_type: "User",
          initiating_user_id: user.id,
          initiating_account_type: initiating_account&.class&.name,
          initiating_account_id: initiating_account&.id,
          receiving_account_type: "BankAccount",
          receiving_account_id: bank_account.id,
          payment_status_id: PaymentStatus.id_for(:pending_approval),
          payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
          payment_mode: self.payment_mode,
          transfer_mode_id: self.transfer_mode_id,
          amount_attributes: {
              # value: payment[:original_amount],
              value: get_balance_due_amount,
              currency_id: Currency.first.id
          },
          note: payment[:note],
          # payment_notification_users: payment[:payment_notification_users],
          date: DateUtils.local_date,
          external_reference_id: payment[:external_reference_id],
          department_id: payment[:department_id],
          category_id: payment[:category_id],
          location_id: payment[:location_id],
          cost_center_id: payment[:cost_center_id],
          company_id: user.company_id,
          api_initiated: false,
          beneficiary_payment_id: beneficiary_payment&.id,
          parent_type: set_payment_parent_type,
          parent_id: set_payment_parent_id,
          reference_resource_type: self.bank_payment_request&.owner&.company&.feature_subscription&.bank_transaction_class&.name,
          invoice_attributes: {
              category_id: payment[:category_id],
              cost_center_id: payment[:cost_center_id],
              inclusive_of_taxes: StringUtils.to_bool(payment[:inclusive_of_taxes]),
              gst_type_id: payment[:gst_type_id],
              tds_slab_id: payment[:tds_slab_id],
              # 
              # BENEFICIARY PAYMENTS WOULD NOW REQUIRE INVOICES
              # 
              invoice_number: payment[:invoice_number],
              date: payment[:date],
              due_date: payment[:due_date],
              tax: payment[:tax],
              invoice_status_id: InwardInvoiceStatus.id_for(:unpaid),
              invoice_type_id: InwardInvoiceType.id_for(:beneficiary),
              company_id: self.user.company_id,
              original_amount_attributes: {
                  value: payment[:original_amount],
                  currency_id: 1
              },
              advance_amount_attributes: {
                  value: payment[:advance_amount],
                  currency_id: 1
              }
          },
          custom_fields: payment[:custom_fields],
          text_fields: payment[:text_fields],
          drop_down_fields: payment[:drop_down_fields],
          multi_select_fields: payment[:multi_select_fields]
      }
    end
    if agreement_type == 'security_deposit'
      self.security_deposits = SecurityDeposit.where(id: self.payment_params.pluck(:parent_id))
    else
      self.beneficiary_payments = BeneficiaryPayment.where(id: self.payment_params.pluck(:parent_id))
    end
  end

  def validate
    if agreement_type == 'security_deposit'
      if self.security_deposit.blank?
        add_message :error, 'Unable to find security deposit'
        return
      end
    end
  end

  def process
    self.init_text_field = []
    self.init_drop_down_field = []
    self.init_multi_select_field =[]
    self.init_multi_select_selction_items=[]
    build_trails = []
    self.payment_params.each do |payment_param|
      custom_fields = payment_param[:custom_fields]
      text_fields = payment_param[:text_fields]
      drop_down_fields = payment_param[:drop_down_fields]
      multi_select_fields = payment_param[:multi_select_fields]
      payment_param.delete(:custom_fields)
      payment_param.delete(:text_fields)
      payment_param.delete(:drop_down_fields)
      payment_param.delete(:multi_select_fields)
      payment_param[:payment_order_id] = self.bank_payment_request.payment_order.id
      payment = ::Payment.new(payment_param)
      # payment = self.bank_payment_request.payment_order.payments.build(payment_param)
      # InvoiceCalculationUtils.new.calculate_tax_and_discounts({}, payment)
      if payment.save

        # Trail will help w.r.t. invoice history
        if from_payment_agreement && ['security_deposit', 'beneficiary'].include?(agreement_type)
          # create_trail
          build_trails << build_trail
        end
        # perform the required calculations
        # beneficiary_payment = self.beneficiary_payments.find(payment_param[:beneficiary_payment_id]) if self.beneficiary_payments.present?
        # beneficiary_payment.update(status_id: BeneficiaryPaymentStatus.id_for(:unpaid)) if beneficiary_payments.present? && !from_payment_agreement

        # payment.save
        # set_custom_fields_invoice(payment, {custom_fields: custom_fields}, true)

        if text_fields.present?
          text_fields.each do |key, value|  
            init_text_field << {
              field_configuration_id: key,
              parent_id: payment.invoice.id,
              parent_type: 'Invoice',
              value_type: 'FieldText',
              value_id: nil,
              value: {
                value: value
              }
            }
          end
        end

        if drop_down_fields.present?
          drop_down_fields.each do |key, value|  
            init_drop_down_field << {
              field_configuration_id: key,
              parent_id: payment.invoice.id,
              parent_type: 'Invoice',
              value_type: 'FieldDropDownSelection',
              value_id: nil,
              value: {
                value_id: value
              }
            }
          end
        end
        if multi_select_fields.present?
          multi_select_fields.each do |key, value|
            init_multi_select_field<< {
                field_configuration_id: key,
                parent_id: payment.invoice.id,
                parent_type: 'Invoice',
                value_type: 'FieldMultiselectSelection',
                value_id: nil,
                field_multiselect_selection: {
                    values: value
                }
            }
          end
        end
      end
    end


    self.beneficiary_payments.update_all(status_id: BeneficiaryPaymentStatus.id_for(:unpaid)) if beneficiary_payments.present? && !from_payment_agreement

    if self.init_text_field.present?
      build_text_custom_fields
    end
    if self.init_drop_down_field.present?
      build_drop_down_custom_fields
    end

    if self.init_multi_select_field.present?
      build_multi_select_custom_fields
    end

    # now once the payment request has been created and the payments saved, we can mark it as open
    max_payment_amount = self.bank_payment_request.payment_order.payments.reload.joins(:amount).pluck(:value).max || 0
    self.bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:open), max_payment_amount: max_payment_amount)
    self.bank_payment_request.payment_order.reload.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval))
    # puts 'SUCCESSFUL!'

    Trail.import build_trails if build_trails.present?

    self.log_data[:end_time] = DateTime.now.utc
    self.logger.info(self.log_data)
  end

  private

  def build_text_custom_fields
    # prepare and build field text so we can get the row id
    field_texts = []
    init_text_field.size.times do |i|
      # we added the import_id because MYSQl doesn't return the ids for the newly inserted batch
      # will use this later to capture the newly created field_texts from the import_ids
      field_texts << FieldText.new(value: self.import_id)
    end
    FieldText.import field_texts

    # capture the newly created fields texts
    newly_created_texts = FieldText.include_soft_deleted.where(value: self.import_id)

    # update its value
    original_values = init_text_field.pluck :value # original list of values
    original_values.each_with_index do |original_value, index|
      newly_created_texts[index].value = original_value[:value]
    end

    # now update the field text ids
    newly_created_texts.each_with_index do |text, index|
      init_text_field[index][:value_id] = text.id
    end

    # prepare and build the custom fields after updating the field text ids
    custom_fields = []
    init_text_field.each do |text|
      custom_fields << CustomField.new(value_id: text[:value_id],
                                       field_configuration_id: text[:field_configuration_id],
                                       parent_id: text[:parent_id],
                                       parent_type: text[:parent_type],
                                       value_type: text[:value_type],
                                       configured_field_value: text[:value][:value])
    end

    # bulk upsert field text with the new values and bulk insert the custom fields in one atomic op
    ActiveRecord::Base.transaction do
      FieldText.import newly_created_texts.to_a, on_duplicate_key_update: [:value]
      CustomField.import custom_fields.to_a
    end
  end

  def build_drop_down_custom_fields
    # prepare and build field drop_down so we can get the row id
    field_drop_down = []
    id = FieldDropDownItem.minimum :id
    dt = DateTime.now + rand(10..50).years
    dt = dt + rand(101..150).years
    value_id = FieldDropDownItem.minimum :id
    value_id = FieldDropDownItem.find(value_id).id
    init_drop_down_field.size.times do |i|
      # we added the import_id because MYSQl doesn't return the ids for the newly inserted batch
      # will use this later to capture the newly created field_drop_down from the import_ids
      field_drop_down << FieldDropDownSelection.new(value_id: value_id, created_at: dt)
    end
    FieldDropDownSelection.import field_drop_down

    # capture the newly created fields drop_downs
    newly_created_drop_downs = FieldDropDownSelection.include_soft_deleted.where(created_at: dt)

    # update its value
    original_values = init_drop_down_field.pluck :value # original list of values
    original_values.each_with_index do |original_value, index|
      newly_created_drop_downs[index].value_id = original_value[:value_id]
      newly_created_drop_downs[index].created_at = DateTime.now
    end

    # now update the field drop_down ids
    newly_created_drop_downs.each_with_index do |drop_down, index|
      init_drop_down_field[index][:value_id] = drop_down.id
      init_drop_down_field[index][:value_name] = drop_down.value.name
    end

    # prepare and build the custom fields after updating the field drop_down ids
    custom_fields = []
    init_drop_down_field.each do |drop_down|
      custom_fields << CustomField.new(value_id: drop_down[:value_id],
                                       field_configuration_id: drop_down[:field_configuration_id],
                                       parent_id: drop_down[:parent_id],
                                       parent_type: drop_down[:parent_type],
                                       value_type: drop_down[:value_type],
                                       configured_field_value: drop_down[:value_name])
    end

    # bulk upsert field drop_down with the new values and bulk insert the custom fields in one atomic op
    ActiveRecord::Base.transaction do
      FieldDropDownSelection.import newly_created_drop_downs.to_a, on_duplicate_key_update: [:value_id, :created_at]
      CustomField.import custom_fields.to_a
    end
  end

  def build_multi_select_custom_fields
    # prepare and build field drop_down so we can get the row id
    field_multi_selects = []
    id = FieldMultiselectItem .minimum :id
    dt = DateTime.now + rand(10..50).years
    dt = dt + rand(101..150).years
    value_id = FieldMultiselectItem .minimum :id
    value_id = FieldMultiselectItem .find(value_id).id
    init_multi_select_field.size.times do |i|
      # we added the import_id because MYSQl doesn't return the ids for the newly inserted batch
      # will use this later to capture the newly created field_drop_down from the import_ids
      field_multi_selects << FieldMultiselectSelection.new(created_at: dt)
    end
    FieldMultiselectSelection.import field_multi_selects

    # capture the newly created multi select selection item
    newly_created_multi_selection = FieldMultiselectSelection.include_soft_deleted.where(created_at: dt)

    # update its value
    original_values = init_multi_select_field.pluck :value # original list of values
    original_values.each_with_index do |original_value, index|
      newly_created_multi_selection[index].created_at = DateTime.now
    end

    # now update the field drop_down ids
    newly_created_multi_selection.each_with_index do |multi_select, index|
      init_multi_select_field[index][:value_id] = multi_select.id
    end


    # prepare and build the custom fields after updating the field drop_down ids
    custom_fields = []
    init_multi_select_field.each do |multi_select|
      custom_fields << CustomField.new(value_id: multi_select[:value_id],
                                       field_configuration_id: multi_select[:field_configuration_id],
                                       parent_id: multi_select[:parent_id],
                                       parent_type: multi_select[:parent_type],
                                       value_type: multi_select[:value_type])
      multi_select[:field_multiselect_selection][:values].each do|value_id|
        init_multi_select_selction_items << FieldMultiselectSelectionItem.new(value_id: value_id,
                                                                              field_multiselect_selection_id: multi_select[:value_id])
      end
    end

    # bulk upsert field drop_down with the new values and bulk insert the custom fields in one atomic op
    ActiveRecord::Base.transaction do
      FieldMultiselectSelection.import newly_created_multi_selection.to_a, on_duplicate_key_update: [:created_at]
      FieldMultiselectSelectionItem.import init_multi_select_selction_items.to_a
      CustomField.import custom_fields.to_a
    end
  end

  def set_custom_fields_invoice(payment, data, save)
    custom_fields = {custom_fields: data[:custom_fields]}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(payment.invoice, FieldParentType.id_for(:invoice), custom_fields)
  end

  def retrieve_bank_account(order_details)
    if order_details[:account_id].present?
      id = order_details[:account_id]
      ba = BankAccount.find_by(id: id)
      return ba
    else
      account_name = order_details[:bank_account_name] || order_details[:name]
      business_name = order_details[:business_name] || order_details[:name]
      ba = BankAccount.find_by(account_number: order_details[:bank_account_number]&.strip, ifsc: order_details[:ifsc]&.strip,
                                           company_id: self.company_id, # name: order_details[:name]&.strip, because account number and IFSC are the only criteria against which we company
                                           account_owner_type: YesBankVendor.name,
                                           name: account_name) # default for API initiations are 2, because they're always for vendors
      vendor = ba&.account_owner || YesBankVendor.find_or_create_by(name: order_details[:name], company_id: self.company_id, business_name: business_name)
      if ba.nil?
        ba = BankAccount.create(name: account_name, account_number: order_details[:bank_account_number]&.strip, ifsc: order_details[:ifsc]&.strip,account_owner: vendor, company_id: self.company_id, default_account: true)
      end
      return ba
    end
  end

  def retrieve_beneficiary_payment(payment, bank_account)
    # bp = BeneficiaryPayment.create(name:)
    vendor_id = bank_account.account_owner_id
    bank_account_id = bank_account.id
    # bp = BeneficiaryPayment.where('vendor_id LIKE ? OR bank_account_id LIKE ?', vendor_id, bank_account_id )
    
    # bp = BeneficiaryPayment.find_by(vendor_id: vendor_id, bank_account_id: bank_account_id )
    # if bp.present?
    #   return bp
    # else
    #   bp_params = beneficiary_payment_params(payment, vendor_id, bank_account_id)
    #   bp = BeneficiaryPayment.new(bp_params)
    #   bp.calculate_tax_and_amount
    #   bp.save
    #   return bp
    # end
    bp_params = beneficiary_payment_params(payment, vendor_id, bank_account_id)
    if from_payment_agreement
      if agreement_beneficiary_payment.present?
        agreement_beneficiary_payment.assign_attributes(bp_params)
        bp = agreement_beneficiary_payment
      end
    else
      bp = BeneficiaryPayment.new(bp_params)
    end
    bp.calculate_tax_and_amount
    bp.save
    return bp
  end

  def find_agreement_related_document
    document = nil
    case
    when agreement_type == 'beneficiary'
      document = user.company.beneficiary_payments.find_by_id agreement_related_document_id
    when agreement_type == 'security_deposit'
      document = user.company.security_deposits.find_by_id agreement_related_document_id
    end
    return document
  end

  def retrieve_initiating_account(company)
    case company&.feature_subscription&.bank_service_provider
    when "YES"
      initiating_account = user.company.yes_bank_company_account
    when "ICICI"
      initiating_account = user.company.icici_bank_company_account
    when "KOTAK"
      initiating_account = user.company.kotak_bank_company_account
    else
      initiating_account = user.company.yes_bank_company_account
    end
    initiating_account
  end

  def beneficiary_payment_params(payment, vendor_id, bank_account_id)
    payment[:date] = payment[:invoice_date] || payment[:date]
    payment[:due_date] = payment[:invoice_due_date] || payment[:due_date]
    {
      name: payment[:name],
      vendor_id: vendor_id,
      bank_account_id: bank_account_id,
      category_id: payment[:category_id],
      cost_center_id: payment[:cost_center_id],
      department_id: payment[:department_id],
      sub_department_id: payment[:sub_department_id],
      company_id: self.company_id,
      gst_type_id: payment[:gst_type_id],
      tds_slab_id: payment[:tds_slab_id],
      payment_notification_users: payment[:payment_notification_users],
      status_id: BeneficiaryPaymentStatus.id_for(:pending),
      inclusive_of_taxes: StringUtils.to_bool(payment[:inclusive_of_taxes]),
      tax: payment[:tax],
      tax_rate_id: payment[:tax_rate_id],
      original_amount_attributes: {
              value: payment[:original_amount],
              currency_id: Currency.first.id
      },
      advance_amount_attributes: {
              value: payment[:advance_amount],
              currency_id: Currency.first.id
      },
      invoice_number: payment[:invoice_number],
      invoice_date: payment[:date],
      invoice_due_date: payment[:due_date]
    }
  end

  def set_payment_parent_type
    if agreement_type == 'security_deposit'
      security_deposit.class.name
    else
      beneficiary_payment&.class&.name
    end 
  end

  def set_payment_parent_id
    if agreement_type == 'security_deposit'
      return security_deposit.id
    else
      return beneficiary_payment.id
    end
  end

  private
  def create_trail
    Trail.create(parent_type: set_payment_parent_type, parent_id: set_payment_parent_id, action_user_id: user.id, action_id: TrailAction.id_for(:payment_ticket_created))
  end

  def build_trail
    Trail.new(parent_type: set_payment_parent_type, parent_id: set_payment_parent_id, action_user_id: user.id, action_id: TrailAction.id_for(:payment_ticket_created))
  end

  def update_status
    self.security_deposit.update(status_id: SecurityDepositStatus.id_for(:processing)) if self.agreement_type == 'security_deposit'
    self.beneficiary_payment.update(status_id: BeneficiaryPaymentStatus.id_for(:processing)) if self.agreement_type == 'beneficiary'
  end

  def get_balance_due_amount
    if self.beneficiary_payment.present?
      return self.beneficiary_payment&.balance_due&.value
    end
    if self.security_deposit.present?
      return self.security_deposit&.payable_amount&.value
    end
  end
end

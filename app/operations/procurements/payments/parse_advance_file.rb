class Procurements::Payments::ParseAdvanceFile < Procurements::Payments::Base

  attr_accessor :header, :contents, :file, :payment_mode, :scheduled_at, :policy,
                :bank_payment_request_params

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:file].blank?
      add_message :error, 'Error loading file. File not uploaded correctly'
      return
    end
  end

  def init
    self.file = params[:file]
    headers = [:purchase_order_id, :advance_amount]
    self.parsed_data = ImportUtil.load_spreadsheet(file, headers,
                                                   {skip_empty_lines: true})
    self.payment_mode = params[:transfer_type]
    self.scheduled_at = params[:scheduled_at]
    policy_id = params[:policy_id]
    self.policy = current_company.policies.find_by(id: policy_id)

  end

  def validate
    errors_found = false
    self.parsed_data.each do |data|
      po_id = data[:purchase_order_id]
      advance_amount = data[:advance_amount]
      purchase_order = current_company.purchase_orders.find_by(id: po_id)
      vendor = purchase_order.vendor

      if purchase_order.blank?
        data[:errors] = "Purchase Order not found"
        errors_found = true
        next
      end
      if advance_amount >= purchase_order.balance_amount&.value
        data[:errors] = "Advance cannot be greater than the balance amount in the PO"
        errors_found = true
        next
      end
      if advance_amount <= 0
        data[:errors] = "Advance amount cannot be less than or equal to 0"
        errors_found = true
        next
      end
      if vendor.bank_accounts.empty?
        data[:errors] = "This vendor doesn't have any bank accounts"
        errors_found = true
        next
      end
    end

    if errors_found
      add_message :error, "Your PO has a few errors, please check the same and retry"
      return
    end
  end

  def process

  end

  def success

  end

  def failure

  end

  private

  def parse_payment_order_params
    params = []
    self.parsed_data.each do |data|
      po_id = data[:purchase_order_id]
      advance_amount = data[:advance_amount]
      purchase_order = current_company.purchase_orders.find_by(id: po_id)
      vendor = purchase_order.vendor
      bank_account = vendor.bank_accounts.first
      payment_order_attributes = {
          initiating_user_id: user.id,
          payment_order_status_id: PaymentOrderStatus.id_for(:creation_in_progress),
          company_id: user.company_id,
          amount_requested_attributes: {
              value: self.requested_amount,
              currency_id: 1
          },
          payment_mode: self.payment_mode,
          initiating_account_type: YesBankCompanyAccount.name,
          receiving_account_type: BankAccount.name,
          payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
          application: "vp",
          currency_id: Currency.first.id,
          api_initiated: false
      }
      bpr_attributes = {
          owner_id: user.id,
          status_id: BankPaymentRequestStatus.id_for(:creation_in_progress),
          controlling_user_id: user.id,
          requested_amount_attributes: {
              value: self.requested_amount,
              currency_id: 1
          },
          beneficiary_type_id: 2,
          policy_id: user.company.policies.default.first.id,
          payment_order_attributes: payment_order_attributes,
          api_initiated: false
      }
    end
  end

end
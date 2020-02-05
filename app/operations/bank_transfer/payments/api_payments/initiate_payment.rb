# Handle multi bank support

class BankTransfer::Payments::ApiPayments::InitiatePayment < BankTransfer::Payments::Base

  attr_accessor :payment_order, :bank_payment_request, :bank_account, :vendor,
                :payment_mode, :company_id, :transfer_mode_id

  class BankTransfer::Payments::ApiPayments::InitiatePayment::PaymentOrderPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payment_order, :bank_payment_request, :response

    def init
      self.payment_order = params[:payment_order]
      self.bank_payment_request = params[:bank_payment_request]
    end

    # def construct_response
    #   response_hash = {
    #       "summary" => {
    #           "order_status" => {
    #               "name" => self.bank_payment_request.status_name(current_user.id)&.humanize,
    #               "identifier" => self.bank_payment_request.status_name(current_user.id)
    #           },
    #           "policy" => {
    #               "id" => self.bank_payment_request.policy&.id,
    #               "name" => self.bank_payment_request.policy&.name
    #           },
    #           "bank_transfer_type" => self.payment_order.payment_mode&.upcase,
    #           "payment_type" => self.payment_order.payment_type&.humanize,
    #           "scheduled_at" => self.payment_order.scheduled_at&.strftime("%d %b %Y"),
    #           "processed_at" => self.payment_order.processed_at&.strftime("%d %b %Y"),
    #           "amount_requested" => self.payment_order.amount_requested&.value,
    #           "amount_processed" => self.payment_order.amount_processed&.value,
    #           "description" => self.bank_payment_request.description,
    #           "note" => self.payment_order.note,
    #           "initiating_user" => self.bank_payment_request.owner.name,
    #           "name" => self.bank_payment_request.name
    #       },
    #       "payments" => payments_array
    #   }
    #   json_response = response_hash.to_json
    #   path = Dir.home + '/certificates/encryption_certificates/qkr_8192.crt'
    #   cert = OpenSSL::X509::Certificate.new(File.read(path))
    #   public_key = cert.public_key
    #   encrypted_response = Base64.encode64(public_key.public_encrypt(json_response))
    # end

    # def payments_array
    #   result = []
    #   self.payment_order.payments.each do |payment|
    #     result << {
    #         "owner_name" => payment.receiving_account&.account_owner&.name,
    #         "name" => payment.receiving_account&.name,
    #         "account_number" => payment.receiving_account.account_number,
    #         "ifsc" => payment.receiving_account.ifsc,
    #         "net_amount" => payment.amount_value,
    #         "status" => payment.payment_status_name,
    #         "id" => payment.id,
    #         "note" => payment.note,
    #         "system_messages" => payment.system_messages.as_json,
    #         "payment_mode" => payment.payment_mode,
    #         "bank_reference_number" => payment.reference_resource&.bank_reference_number
    #     }
    #   end
    #   result
    # end
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end

    if params[:amount].blank?
      add_message :error, "Amount cannot be empty"
      return
    end

    if params[:account_number].blank?
      add_message :error, "Account number cannot be blank"
      return
    end

    if params[:ifsc].blank?
      add_message :error, "IFSC cannot be blank"
      return
    end

    pattern = Regexp.new(Constants::VALID_IFSC)
    unless params[:ifsc] =~ pattern
      add_message :error, "Invaid IFSC"
      return
    end

    if params[:name].blank?
      add_message :error, "Name of beneficiary is compulsory"
      return
    end

    if params[:mode].blank?
      add_message :error, "Payment mode has to be specified"
      return
    end
  end

  def init
    self.company_id = user.company_id
    self.payment_mode = params[:mode]
    mode_id = TransferMode.find_by(name: self.payment_mode.downcase)
    self.transfer_mode_id = user.company.transfer_modes.find_by(mode_id: mode_id)&.id
    create_beneficiary
    create_bank_payment_request
  end

  def validate
    if self.bank_account.disabled?
      add_message :error, "You cannot make transfers to this bank account as it has been blacklisted"
      add_system_message :error, self.payment_order.payments.first, "You cannot make transfers to this vendor because they have been blacklisted"
      return
    end
    if self.bank_account.on_hold?
      add_message :error, "You cannot make transfers to this bank account as it has been blacklisted"
      add_system_message :error, self.payment_order.payments.first, "You cannot make transfers to this vendor because they have been blacklisted"
      return
    end
    account_owner = self.bank_account.account_owner
    if account_owner.is_a?(YesBankVendor) && account_owner.disabled?
      add_message :error, "You cannot make transfers to this vendor because they have been blacklisted"
      return
    end
  end

  def process
    # now that we have the payment request and the payment order with us,
    # we can initiate the payment using the payment processor
    op = AccountManager::Payments::PaymentProcessor.(user, {payment_order: self.payment_order, bank_transfer_type: self.payment_mode, background: true})
    if op.success?
      # mark the bank payment request as credited, and add a trail
      # update the bank_payment_request to credited
      bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:credited), controlling_user: nil, controlling_user_role_id: nil,
                                  controlling_for_user_id: nil, controlling_for_user_role_id: nil)
      # create a trail to show that the BPR was credited
      bank_payment_request.bank_payment_request_trails.create action_user: user,
                                                              action_user_role_id: UserRole.id_for(:initiator),
                                                              action_id: BankPaymentRequestTrailAction.id_for(:credit),
                                                              modified_user_id: nil,
                                                              modified_user_role_id: nil
    else
      add_message :error, op.messages[:error]
      payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:failed))
      payment_order.payments.update_all(payment_status_id: PaymentStatus.id_for(:failed))
      payment_order.payments.each do |payment|
        payment.system_messages.create(content: op.messages[:error].to_sentence,
                                       system_message_type_id: SystemMessageType.id_for(:error))
      end
      return
    end

  end

  def post_process
    add_message :success, "Payment successfully processed. You can check the status in some time"
  end

  def success
    params[:payment_order] = self.payment_order
    params[:bank_payment_request] = self.bank_payment_request
    BankTransfer::Payments::ApiPayments::InitiatePayment::PaymentOrderPresenter.new(user, params, messages)
  end

  private

  def create_beneficiary
    ba = BankAccount.non_deleted.find_by(account_number: params[:account_number]&.strip, ifsc: params[:ifsc]&.strip,
                                         company_id: self.company_id)
    self.vendor = ba&.account_owner || YesBankVendor.find_or_create_by(name: params[:name], business_name: params[:name], company_id: self.company_id)
    ba&.update(is_deleted: false) # i.e. if the bank account already exists, mark it as non deleted
    if ba.nil?
      ba = BankAccount.create(name: params[:name], account_number: params[:account_number]&.strip, ifsc: params[:ifsc]&.strip,
                              account_owner: vendor, company_id: self.company_id, default_account: true)

    end
    self.bank_account = ba
  end

  def create_bank_payment_request
    initiating_account = retrieve_initiating_account(user.company)
    payment_params = {
        payment_type_id: PaymentType.id_for(:credit),
        application: "vp",
        receiving_user_type: self.bank_account.account_owner.class.name,
        receiving_user_id: self.bank_account.account_owner_id,
        initiating_user_type: "User",
        initiating_user_id: user.id,
        initiating_account_type: initiating_account.class.name,
        initiating_account_id: initiating_account.id,
        receiving_account_type: "BankAccount",
        receiving_account_id: self.bank_account.id,
        payment_status_id: PaymentStatus.id_for(:pending_approval),
        payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
        payment_mode: params[:mode],
        company_id: user.company_id,
        amount_attributes: {
          value: params[:amount],
          currency_id: Currency.first.id
      },
        note: params[:note],
        date: DateUtils.local_date,
        external_reference_id: params[:external_reference_id],
        transfer_mode_id: transfer_mode_id,
        api_initiated: true
    }
    payment_order_params = {
        initiating_user_id: user.id,
        payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval),
        company_id: user.company_id,
        amount_requested_attributes: {
          value: params[:amount],
          currency_id: 1
      },
        payment_mode: params[:mode],
        initiating_account_type: initiating_account.class.name,
        receiving_account_type: BankAccount.name,
        payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
        application: "vp",
        currency_id: Currency.first.id,
        api_initiated: true,
        transfer_mode_id: transfer_mode_id,
        payments_attributes: [
          payment_params
      ]
    }
    payment_request_params = {
        owner_id: user.id,
        status_id: BankPaymentRequestStatus.id_for(:open),
        controlling_user_id: user.id,
        requested_amount_attributes: {
          value: params[:amount],
          currency_id: 1
      },
        beneficiary_type_id: 2,
        policy_id: user.company.policies.default.first.id,
        transfer_mode_id: transfer_mode_id,
        api_initiated: true,
        payment_order_attributes: payment_order_params
    }
    self.bank_payment_request = BankPaymentRequest.new(payment_request_params)
    unless self.bank_payment_request.save
      add_message :error, self.bank_payment_request.errors.full_messages
      return
    end
    self.payment_order = self.bank_payment_request.payment_order
  end


end
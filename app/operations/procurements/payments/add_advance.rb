# This will generate a new advance payment item
# After procurement is created and a purchase order generated, if the user updates the po with advance payment, this operation will be called
# this takes in procurement id and the purchase order id and creates a new payment item for it.
# this individual payment is not yet linked to a bankpaymentrequest/payment ticket.
# to link this to a bpr, a different operation will be called

# TODO
# handle multiple advances
# adding multiple advances should be done in the background
# add validations

class Procurements::Payments::AddAdvance < Procurements::Payments::Base

  attr_accessor :purchase_order, :scheduled_at, :payment_mode, :policy_id,
                :description, :bank_payment_request, :advance_amount,
                :payment_request_params, :receiving_account,
                :payment, :procurement

  # class Procurements::Payments::AddAdvance < BaseOperation::BasePresenter::SuccessPresenter

  #   attr_accessor :bank_payment_request

  #   def init
  #     self.bank_payment_request = params[:bank_payment_request]
  #   end

  # end

  def init
    id = params[:id] || params[:purchase_order_id] || params[:po_id]
    self.purchase_order = user.company.purchase_orders.find_by(id: id)
    self.procurement = user.company.procurements.find_by id: params[:procurement_id]
    self.scheduled_at = params[:scheduled_at]
    self.payment_mode = params[:payment_mode]
    self.policy_id = params[:policy_id]
    self.advance_amount = params[:advance_amount] || 999
    # self.receiving_account = user.company.bank_accounts.find_by(id: params[:receiving_account_id])
    puts "ADDADVANCE from init params", params.inspect

    binding.pry
  end

  def validate
    if self.purchase_order.blank?
      add_message :error, "Purchase Order not found"
      return
    end

    # WRAP THIS IN BANK PAYMENT REQUEST CONDITOJN
    # if self.advance_amount.blank?
    #   add_message :error, "You need to enter a payable amount to create an order"
    #   return
    # end

    # if self.advance_amount.to_f >= self.purchase_order.balance_amount.value
    #   add_message :error, "You cannot pay more than the purchase order total as advance"
    #   return
    # end

    # if self.receiving_account.blank?
    #   add_message :error, "Receiving bank account not found"
    #   return
    # end
  end

  def process
    self.payment_request_params = advance_payment_request_params
    puts "ADDADVANCE from process",self.payment_request_params.inspect
    # self.bank_payment_request = user.bank_payment_requests.build(self.payment_request_params)
    # if self.bank_payment_request.save
    #   # any changes to be made here? #todo
    # else
    #   add_message :error, self.bank_payment_request.errors.full_messages
    # end

    self.payment = Payment.new(self.payment_request_params)

    unless self.payment.save
      add_message :error, self.payment.errors.full_messages
    end




  end

  def post_process
    add_message :success, "Advance Payment Added"

  end

  # def success
  #   params[:bank_payment_request] = self.bank_payment_request
  #   Procurements::Payments::AddAdvance.new(user, params, messages)
  # end


  private

  def advance_payment_request_params
    payment_params = {
        payment_type_id: PaymentType.id_for(:credit),
        application: "vp",
        
        # receiving_user_type: self.receiving_account&.account_owner&.class&.name,
        receiving_user_type: params[:receiving_user_type],
        
        # receiving_user_id: self.receiving_account&.account_owner_id,
        receiving_user_id: params[:receiving_user_id],

        initiating_user_type: "User",
        initiating_user_id: user.id,
        initiating_account_type: user.company.yes_bank_company_account&.class&.name,
        initiating_account_id: user.company.yes_bank_company_account&.id,
        receiving_account_type: "BankAccount",
        
        # receiving_account_id: self.receiving_account.id,
        receiving_account_id: params[:receiving_account_id],

        payment_status_id: PaymentStatus.id_for(:pending_approval),
        payment_purpose_id: PaymentPurpose.id_for(:advance_against_purchase_order),
        payment_mode: self.payment_mode,
        amount_attributes: {
            value: self.advance_amount,
            currency_id: Currency.first.id
        },
        date: DateUtils.local_date,
        purchase_order_id: self.purchase_order.id,
        procurement_id: self.procurement.id
                      }
    # payment_order_params = {
    #     initiating_user: user,
    #     payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval),
    #     company_id: user.company_id,
    #     amount_requested_attributes: {
    #         value: self.advance_amount,
    #         currency_id: 1
    #     },
    #     payment_mode: self.payment_mode,
    #     initiating_account_type: user.company.yes_bank_company_account&.class&.name,
    #     receiving_account_type: "BankAccount",
    #     payment_purpose_id: PaymentPurpose.id_for(:advance_against_purchase_order),
    #     application: RequestStore.store[:current_app],
    #     currency_id: 1,
    #     scheduled_at: self.scheduled_at,
    #     payments_attributes: payment_params
    # }
    # bank_payment_request_params = {
    #     owner_id: user.id,
    #     status_id: BankPaymentRequestStatus.id_for(:open),
    #     controlling_user_id: user.id,
    #     requested_amount_attributes: {
    #         value: self.advance_amount,
    #         currency_id: 1
    #     },
    #     description: self.description,
    #     beneficiary_type_id: 2, # this is because a purchase order will always come from a vendor
    #     policy_id: self.policy_id,
    #     payment_order_attributes: payment_order_params
    # }
    return payment_params
  end

end
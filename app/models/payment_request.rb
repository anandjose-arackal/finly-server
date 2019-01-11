# non persistent model that holds info about a particular payment order - things like initiating account,
# receiving account etc.
# background - whether the request is to be executed real time, or if it should be scheduled in the BG
# payment items will most likely be a hash of details that are relevant to that particular payment object

class PaymentRequest < NonPersistentModel

  AVAILABLE_ACCOUNT_TYPES = [nil, ItzCashCompanyAccount.name, YesBankCompanyAccount.name, UserWallet.name, CashOnHand.name, Card.name, BankAccount.name, VendorPaymentWallet.name, VirtualBankAccount.name, UserPocket.name]

  attr_accessor :company_id, :scheduled_at, :background, :payment_purpose_id,
                :payment_items,
                :initiating_resource_id, :initiating_resource_type,
                :initiating_account_id, :initiating_account_type,
                :receiving_account_type,
                :payment_order_status_id,
                :payment_items,
                :payment_type_id,
                :currency_id,
                :bank_transfer_type,
                :payment_order,
                :post_operation_actions

  belongs_to :company, optional: true
  belongs_to :initiating_resource, optional: true, polymorphic: true
  belongs_to :payment_purpose, optional: true
  belongs_to :initiating_account, optional: true, polymorphic: true
  belongs_to :currency, optional: true

  validate :company_id_presence
  validates :initiating_resource, presence: true
  validates :initiating_resource_type, inclusion: {in: [User.name, AdminUser.name, nil]}
  validates :payment_purpose_id, presence: true
  validates :initiating_account_type, inclusion: {in: AVAILABLE_ACCOUNT_TYPES}
  validates :receiving_account_type, inclusion: {in: AVAILABLE_ACCOUNT_TYPES}
  validate :payment_items_validity

  def self.call(initiating_resource, initiating_account, receiving_account_type, payment_type, payment_purpose, options = {})
    options = {} if options.nil?
    self.new({
                 initiating_resource: initiating_resource,
                 initiating_account: initiating_account,
                 receiving_account_type: receiving_account_type,
                 payment_purpose_id: PaymentPurpose.id_for(payment_purpose&.to_sym),
                 payment_type_id: PaymentType.id_for(payment_type&.to_sym),
                 scheduled_at: options[:scheduled_at],
                 currency_id: options[:currency_id],
                 background: !!options[:background],
                 bank_transfer_type: options[:bank_transfer_type],
                 company_id: options[:company_id]
             })
  end

  def post_initialize(attributes= {})
    # Set defaults
    if self.initiating_resource.present? and self.initiating_resource.class.name == 'User'
      self.company_id = self.initiating_resource.company_id
    end
    self.currency_id ||= Currency.id_for(:INR)
    self.payment_order_status_id ||= retrieve_payment_order_status
    self.payment_items ||= []
    self.background ||= false
    self.post_operation_actions = []
  end

  def add_post_operation_action(operation, payload)
    self.post_operation_actions = [] if self.post_operation_actions.nil?
    self.post_operation_actions << {operation: operation, payload: payload}
  end

  def retrieve_payment_order_status
    if self.scheduled_at.present? && self.scheduled_at > DateUtils.local_date
      PaymentOrderStatus.id_for(:scheduled)
    else
      PaymentOrderStatus.id_for(:pending)
    end
  end

  def request_total
    total = 0
    self.payment_items.each do |pi|
      total += pi[:amount]&.to_f
    end
    total
  end

  def add_payment_item(payment_item)
    return false if payment_item.nil?
    if self.payment_items.nil?
      self.payment_items = []
    end
    if payment_item.class.name == 'PaymentRequest::PaymentItem'
      payment_item.payment_request = self
      if payment_order.present?
        payment_item.build_payment(payment_order)
      end
      self.payment_items << payment_item
    else
      return false
    end
    true
  end

  def add_payment_items(payment_items)
    return false unless payment_items.is_a?(Array)
    payment_items.all.each do |payment_item|
      add_payment_item payment_item
    end
    true
  end

  def payment_items_validity
    self.payment_items&.each do |payment_item|
      unless payment_item.valid?
        payment_item.errors.full_messages.each { |error| errors.add :payment, error }
      end
    end
  end

  def company_id_presence
    if self.initiating_resource_type == "User"
      if company_id.blank?
        errors.add(:company_id, "can't be blank")
      end
    end
  end

  def build_payment_order
    unless self.payment_order.present?
      cc = current_company || Company.find_by(id: self.company_id)
      self.payment_order = cc.payment_orders.build payment_order_params
    end
    self.payment_order
    self.payment_items.each do |item|
      item.build_payment(self.payment_order)
    end
    self.payment_order.post_operation_actions&.destroy_all
    post_operation_actions&.each do |action_params|
      action_params[:post_operatable] = self.payment_order
      self.payment_order.post_operation_actions.build action_params
    end
    self.payment_order
  end

  def current_company
    (RequestStore.store[:current_company] || initiating_resource&.company) rescue nil
  end

  def payment_order_params
    {
        payment_purpose_id: payment_purpose_id,
        payment_order_status_id: retrieve_payment_order_status,
        initiating_user_id: initiating_resource_id,
        company_id: self.company_id,
        scheduled_at: scheduled_at,
        initiating_account_type: initiating_account_type,
        receiving_account_type: receiving_account_type,
        currency_id: currency_id,
        application: RequestStore.store[:current_app],
        payment_mode: bank_transfer_type,
        amount_requested_attributes: {
            value: request_total,
            currency_id: currency_id
        }
    }
  end

  class PaymentRequest::PaymentItem < NonPersistentModel
    attr_accessor :receiving_resource_id, :receiving_resource_type,
                  :receiving_account_id, :receiving_account_type,
                  :amount,
                  :payment_request,
                  :reference_resource,
                  :note,
                  :post_operation_actions,
                  :payment

    delegate :initiating_resource, :initiating_resource_id, :initiating_resource_type,
             :initiating_account, :initiating_account_id, :initiating_account_type, :scheduled_at,
             :payment_type_id, :currency_id, :payment_purpose_id, to: :payment_request, allow_nil: true

    belongs_to :receiving_resource, optional: true, polymorphic: true
    belongs_to :receiving_account, optional: true, polymorphic: true

    validates :amount, presence: true
    validates :payment_request, presence: true
    validate :payment_request_receiving_account_type
    validate :receiving_account_presence

    def self.call(receiving_resource, receiving_account, amount, options = {})
      if options.nil?
        options = {}
      end
      self.new({
                   receiving_resource: receiving_resource,
                   receiving_account: receiving_account,
                   amount: amount,
                   reference_resource: options[:reference_resource],
                   note: options[:note]
               })
    end

    def post_initialize(attributes={})
      self.post_operation_actions = []
    end

    def add_post_operation_action(operation, payload)
      self.post_operation_actions = [] if self.post_operation_actions.nil?
      self.post_operation_actions << {operation: operation, payload: payload}
    end

    def payment_status_id
      PaymentStatus.id_for(:pending)
    end

    def receiving_account_presence
      unless [PaymentPurpose.id_for(:reimbursement_outside_finly)].include?(self.payment_purpose_id)
        if receiving_account.nil?
          errors.add(:receiving_account, "cannot be blank")
        end
      end
    end

    def payment_request_receiving_account_type
      return if self.receiving_account_type.blank?
      unless self.payment_request and self.payment_request.receiving_account_type == self.receiving_account_type
        errors.add :invalid, 'receiving account type'
      end
    end

    def date
      (self.payment_request&.scheduled_at or Date.today)
    end

    def build_payment(payment_order)
      unless self.payment.present?
        self.payment = payment_order.payments.build payment_params
      end
      self.payment.post_operation_actions&.destroy_all
      post_operation_actions&.each do |action_params|
        action_params[:self.payment] = self.payment_order
        self.payment.post_operation_actions.build action_params
      end
      self.payment
    end

    def payment_params
      {
          payment_type_id: payment_type_id,
          application: RequestStore.store[:current_app],
          receiving_user_id: receiving_resource_id,
          receiving_user_type: receiving_resource_type,
          initiating_user_id: initiating_resource_id,
          initiating_user_type: initiating_resource_type,
          initiating_account_id: initiating_account_id,
          initiating_account_type: initiating_account_type,
          receiving_account_type: receiving_account_type,
          receiving_account_id: receiving_account_id,
          payment_status_id: payment_status_id,
          payment_purpose_id: payment_purpose_id,
          payment_mode: payment_request.bank_transfer_type,
          amount_attributes: {
              value: amount,
              currency_id: currency_id
          },
          date: date,
          reference_resource: reference_resource,
          note: note
      }
    end


  end

end
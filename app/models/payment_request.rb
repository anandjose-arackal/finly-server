# non persistent model that holds info about a particular payment order - things like initiating account,
# receiving account etc.
# background - whether the request is to be executed real time, or if it should be scheduled in the BG
# payment items will most likely be a hash of details that are relevant to that particular payment object

class PaymentRequest < NonPersistentModel

  AVAILABLE_ACCOUNT_TYPES = [nil, ItzCashCompanyAccount.name, YesBankCompanyAccount.name, UserWallet.name, CashOnHand.name, Card.name]

  attr_accessor :company_id, :scheduled_at, :background, :payment_purpose_id,
                :payment_items,
                :initiating_resource_id, :initiating_resource_type,
                :initiating_account_id, :initiating_account_type,
                :receiving_account_type,
                :payment_order_status_id,
                :payment_items,
                :payment_type_id,
                :currency_id

  belongs_to :company
  belongs_to :initiating_resource, polymorphic: true
  belongs_to :payment_purpose
  belongs_to :initiating_account, polymorphic: true
  belongs_to :currency

  validates :company_id, presence: true
  validates :initiating_resource, presence: true
  validates :initiating_resource_type, inclusion: {in: [User.name, AdminUser.name]}
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
                 background: !!options[:background]
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
  end

  def retrieve_payment_order_status
    if self.scheduled_at.present? && self.scheduled_at > DateUtils.local_date
      return PaymentOrderStatus.id_for(:scheduled)
    else
      return PaymentOrderStatus.id_for(:pending)
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

  def request_currency_id
    # for now will just be INR, can change in the future
    Currency.id_for(:INR)
  end

  class PaymentRequest::PaymentItem < NonPersistentModel
    attr_accessor :receiving_resource_id, :receiving_resource_type,
                  :receiving_account_id, :receiving_account_type,
                  :amount,
                  :payment_request

    delegate :initiating_resource,:initiating_resource_id,:initiating_resource_type,
             :initiating_account, :initiating_account_id, :initiating_account_type, :scheduled_at,
             :payment_type_id, :currency_id, :payment_purpose_id, to: :payment_request, allow_nil: true

    belongs_to :receiving_resource, polymorphic: true
    belongs_to :receiving_account, polymorphic: true

    validates :receiving_account, presence: true
    validates :amount, presence: true
    validates :payment_request, presence: true
    validate :payment_request_receiving_account_type

    def self.call(receiving_resource, receiving_account, amount)
      self.new({
                   receiving_resource: receiving_resource,
                   receiving_account: receiving_account,
                   amount: amount
               })
    end

    def payment_status_id
      PaymentStatus.id_for(:pending)
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

  end

end
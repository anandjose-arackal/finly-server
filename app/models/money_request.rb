# == Schema Information
#
# Table name: money_requests
#
#  id                                 :integer          not null, primary key
#  name                               :string(255)
#  user_id                            :integer          not null
#  policy_id                          :integer          not null
#  payment_mode_id                    :integer          not null
#  payment_id                         :integer
#  required_by_date                   :date
#  status_id                          :integer          not null
#  controlling_user_id                :integer
#  controlling_user_role_id           :integer
#  controlling_for_user_id            :integer
#  controlling_for_user_role_id       :integer
#  loaded_by                          :integer
#  loaded_at                          :datetime
#  submitted_at                       :datetime
#  memo                               :text(65535)
#  accounted                          :boolean          default(FALSE), not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  is_deleted                         :boolean          default(FALSE), not null
#  submitted_amount_id                :integer
#  processed_amount_id                :integer
#  auto_approve                       :boolean
#  money_request_processor_mapping_id :integer
#  approved_at                        :datetime
#  travel_request_id                  :integer
#  destination_pocket_id              :integer
#  created_by_id                      :integer
#





class MoneyRequest < ApplicationRecord
  include OperationCallbacks,
          MathUtil,
          SoftDeletable,
          FieldCustomizer::CustomizableValidation,
          FindByOrderedIds

  has_many :email_authorizations, as: :authorizable
  belongs_to :status, optional: true, class_name: 'MoneyRequestStatus'
  belongs_to :user, optional: true, inverse_of: :money_requests
  belongs_to :card, optional: true
  belongs_to :loaded_by, optional: true, class_name: 'User'
  belongs_to :controlling_user, optional: true, class_name: 'User'
  belongs_to :controlling_user_role, optional: true, class_name: 'UserRole'
  belongs_to :controlling_for_user, optional: true, class_name: 'User'
  belongs_to :controlling_for_user_role, optional: true, class_name: 'UserRole'
  belongs_to :payment_mode, optional: true
  belongs_to :status, optional: true, class_name: 'MoneyRequestStatus'
  belongs_to :policy, optional: true
  belongs_to :payment, optional: true
  belongs_to :money_request_processor_mapping, optional: true
  belongs_to :destination_pocket, optional: true, class_name: "UserPocket"
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :modified_by, class_name: 'User', optional: true

  has_many :custom_fields, as: :parent, dependent: :destroy

  has_many :tracks, class_name: 'MoneyRequestTrack', foreign_key: :money_request_id, dependent: :destroy
  has_many :comments, class_name: 'MoneyRequestComment', foreign_key: :money_request_id, dependent: :destroy
  has_many :items, class_name: 'MoneyRequestItem', foreign_key: :money_request_id, dependent: :destroy

  belongs_to :travel_request, optional: true

  # submission amount for determining the approving manager and finance manager
  belongs_to :submitted_amount, optional: true, class_name: "Amount"
  belongs_to :processed_amount, optional: true, class_name: "Amount"

  accepts_nested_attributes_for :submitted_amount
  accepts_nested_attributes_for :processed_amount
  delegate :submitted_amount_value, to: :submitted_amount

  scope :with_id, ->(id) { where id: id }
  scope :without_id, ->(id) { where.not id: id }
  scope :with_policy, ->(policy_id) { where policy_id: policy_id }
  scope :with_user, ->(user_id) { where user_id: user_id }
  scope :open, -> { where status_id: MoneyRequestStatus.id_for(:open) }
  scope :approved, -> { where status_id: MoneyRequestStatus.id_for(:approved) }
  scope :credited, -> { where status_id: MoneyRequestStatus.id_for(:credited) }
  scope :credited_money_request, -> { where status_id: MoneyRequestStatus.id_for(:credited) }
  scope :approved_money_request, -> { where status_id: MoneyRequestStatus.id_for(:approved) }
  scope :submitted_after, ->(date) { where 'submitted_at > ?', date }
  scope :processing, -> { where status_id: MoneyRequestStatus.id_for(:processing) }
  scope :owner, ->(user_id) { where user_id: user_id }
  scope :non_owner, ->(user_id) { where.not user_id: user_id }
  scope :not_open, -> { where.not status_id: MoneyRequestStatus.id_for(:open) }
  scope :include_user, -> { includes :user }
  scope :with_payment, -> { where.not payment_id: nil }
  scope :without_payment, -> { where payment_id: nil }
  scope :with_controlling_user_role_id, -> (role_id) { where controlling_user_role_id: role_id }
  scope :with_controlling_user_id, -> (user_id) { where controlling_user_id: user_id }
  scope :with_items, -> { joins(:items) }
  scope :include_user_accounts, -> { includes user: [:bank_accounts, :expense_cards] }
  scope :group_user_id, -> { group :user_id }
  scope :group_user, -> { group :user }
  scope :sum_total, -> { joins(:items).joins({items: :amount}).sum(:value) }
  scope :without_associated_processor, -> { where money_request_processor_mapping_id: nil }
  scope :not_destroyable, -> { where.not status_id: MoneyRequestStatus.ids_for([:open, :rejected, :retracted]) }
  scope :skip_pending, -> { where.not status_id: MoneyRequestStatus.id_for(:pending)}
  scope :without_user, -> (user_id) { where.not user_id: user_id }
  scope :status_pending, -> { where status_id: MoneyRequestStatus.id_for(:pending)}

  scope :awaiting_approval_of_user, ->(user_id, role_id) { where(status_id: MoneyRequestStatus.id_for(:processing))
                                                               .where(controlling_user_id: user_id).where(controlling_user_role_id: role_id) }
  scope :filter_mapping_id, -> (id) { where money_request_processor_mapping_id: id }
  scope :pluck_mapping_id, -> { pluck :money_request_processor_mapping_id }

  scope :total_value, -> { joins(items: :amount).sum(:value) }

  # scoping by payment type - cash or card
  scope :via_cash_only, -> { where payment_mode_id: PaymentMode.id_for(:cash) }
  scope :via_card_only, -> { where payment_mode_id: PaymentMode.id_for(:card) }

  # scope :filter_status, ->(status_id) { where status_id: status_id }
  scope :filter_status, ->(status_id, user_id) do
    case status_id
    when 99, '99'
      where(controlling_user_id: user_id).where.not(status_id: MoneyRequestStatus.ids_for(:retracted, :open, :rejected))
    else
      where status_id: status_id
    end
  end
  scope :filter_user_id, ->(id) { where(user_id: id) }
  scope :filter_request_id, ->(id) { where(id: id) }
  scope :filter_search, ->(value) do
    # user_ids = self.pluck(:id)
    # user_ids = User.with_id(user_ids).where("name like :value OR email like :value", value: "%#{value}%").pluck(:id)
    money_requests = arel_table
    where(money_requests[:name].matches("%#{value}%").or(money_requests[:id].eq(value)))
  end
  scope :filter_date, ->(date_from = nil, date_to = nil) do
    # sample params: filter_date[expense, 2016-03-01, 2016-03-20]
    unless date_from.blank? && date_to.blank?
      date_from = "1990-01-01" if date_from.blank?
      date_to = "2100-01-01" if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      # date_to = DateUtils.local_date if date_to.blank?
      money_requests = arel_table
      where(money_requests[:created_at].gteq(date_from).and(money_requests[:created_at].lteq(date_to)))
    end
  end
  scope :filter_submitted_date, ->(date_from = nil, date_to = nil) do
    # sample params: filter_date[expense, 2016-03-01, 2016-03-20]
    unless date_from.blank? && date_to.blank?
      date_from = "1990-01-01" if date_from.blank?
      date_to = "2100-01-01" if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      # date_to = DateUtils.local_date if date_to.blank?
      money_requests = arel_table
      where(money_requests[:submitted_at].gteq(date_from).and(money_requests[:submitted_at].lteq(date_to)))
    end
  end
  scope :filter_approved_date, ->(date_from = nil, date_to = nil) do
    # sample params: filter_date[expense, 2016-03-01, 2016-03-20]
    unless date_from.blank? && date_to.blank?
      date_from = "1990-01-01" if date_from.blank?
      date_to = "2100-01-01" if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      # date_to = DateUtils.local_date if date_to.blank?
      money_requests = arel_table
      where(money_requests[:approved_at].gteq(date_from).and(money_requests[:approved_at].lteq(date_to)))
    end
  end

  scope :filter_required_by_date, ->(date_from = nil, date_to = nil) do
    # sample params: filter_date[expense, 2016-03-01, 2016-03-20]
    unless date_from.blank? && date_to.blank?
      date_from = "1990-01-01" if date_from.blank?
      date_to = "2100-01-01" if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      # date_to = DateUtils.local_date if date_to.blank?
      money_requests = arel_table
      where(money_requests[:required_by_date].gteq(date_from).and(money_requests[:required_by_date].lteq(date_to)))
    end
  end
  scope :filter_policy, -> (policy_id) { where(policy_id: policy_id) }
  scope :settlement_viewable, -> { where status_id: [MoneyRequestStatus.id_for(:approved), MoneyRequestStatus.id_for(:credited)] }
  scope :sort_for_personal, -> { joins(:status).reorder('money_request_statuses.order ASC, money_requests.submitted_at DESC, money_requests.created_at DESC') }
  scope :not_settled, -> { where money_request_processor_mapping_id: nil }
  scope :with_processor_mapping, -> (id) { where money_request_processor_mapping_id: id }
  scope :with_destination_pocket_id, -> (id) {
    where destination_pocket_id: id
  }

  scope :order_by_controlling_user, ->(user_id, manager=false) {
    if user_id.present?
      ids = pluck(:id)
      controlling_money_requests = where(controlling_user_id: user_id)
      if manager
        controlling_money_requests = controlling_money_requests.where(status_id: MoneyRequestStatus.id_for(:processing))
      end
      controlling_ids = controlling_money_requests.pluck(:id)
      ordered_ids = controlling_ids + (ids - controlling_ids)
      find_ordered(ordered_ids)
    end
  }

  scope :order_by, ->(type, user_id=nil){
    case type
    when :created_at
      reorder(created_at: :desc)
    when :manager_controlling_user
      order_by_controlling_user(user_id, true)
    when :controlling_user
      order_by_controlling_user(user_id)
    when :submitted_at
      reorder(submitted_at: :desc)
    end
  }
  scope :include_details, -> {includes(:user, :policy, :status, :payment_mode, :controlling_user, :user, {items: [{amount: [:currency]}]})}

  accepts_nested_attributes_for :custom_fields

  accepts_nested_attributes_for :items
  delegate :status_name, to: :status
  delegate :payment_mode_name, to: :payment_mode

  default_scope { order(status_id: :asc, submitted_at: :desc, created_at: :desc) }

  validates :policy_id, presence: true
  validate :cash_pocket_presence

  alias_attribute :purpose, :memo

  field_customization_key :money_request
  customizable_validate :purpose, presence: false, scope: [:user, :company]
  customizable_validate :required_by_date, presence: false, scope: [:user, :company]

  before_save :handle_name
  before_save :handle_nil_amount
  before_create :create_items

  attr_accessor :cache_users

  def open?
    status_id == MoneyRequestStatus.id_for(:open)
  end

  def processing?
    status_id == MoneyRequestStatus.id_for(:processing)
  end

  def retracted?
    status_id == MoneyRequestStatus.id_for(:retracted)
  end

  def rejected?
    status_id == MoneyRequestStatus.id_for(:rejected)
  end

  def approved?
    status_id == MoneyRequestStatus.id_for(:approved)
  end

  def credited?
    status_id == MoneyRequestStatus.id_for(:credited)
  end

  def editable?
    self.status_id == MoneyRequestStatus.id_for(:open) ||
        self.status_id == MoneyRequestStatus.id_for(:rejected) ||
        self.status_id == MoneyRequestStatus.id_for(:retracted) ||
        self.status_id == MoneyRequestStatus.id_for(:pending) ||
        self.status_id == MoneyRequestStatus.id_for(:processing)
  end

  def can_submit?
    open? or retracted? or rejected?
  end

  def can_retract?
    processing? or (approved? and auto_approve)
  end

  def can_destroy?
    (open? or retracted? or rejected?)
  end

  def can_unapprove?
    (processing? or approved?)
  end

  def can_take_control?
    processing?
  end

  def payment_mode_card?
    self.payment_mode_id == PaymentMode.id_for(:card)
  end

  def payment_mode_cash?
    self.payment_mode_id == PaymentMode.id_for(:cash)
  end

  def relative_status_name(user)
    if processing? and controlling_user? user
      return 'Pending Review'
    end
    name = status.name
    name[0].upcase + name[1..name.length]
  end

  def base_currency
    currency = Currency.first
    if payment_mode_id == PaymentMode.id_for(:cash) and destination_pocket.present?
      currency = destination_pocket.base_currency
    end
    currency
  end

  def total_amount
    return precision_value(self.items.with_amount.sum(:value)) if self.items.present?
    0
  end

  def controlling_user?(user)
    return false if self.controlling_user.blank?
    self.controlling_user.id == user.id
  end

  def payment_pending?
    self.payment_id.blank?
  end

  def versioned_policy
    # if self.submitted_at.present?
    #   if self.policy
    #     return self.policy.paper_trail.version_at self.submitted_at, has_many: true, has_one: true, belongs_to: true
    #   end
    # end
    self.policy
  end

  def final_approver
    return nil unless self.approved? or self.credited?
    tracks = self.tracks.with_action(MoneyRequestTrackingAction.id_for(:approve))
    if tracks.present?
      return tracks.last.action_user
    end
    nil
  end

  def self.get_default_name(user)
    "#{user.name.downcase.split.join('_')}_#{Time.now.strftime("%d.%m.%y")}"
  end

  def cash_pocket_presence
    if self.id.present? and self.payment_mode_id == PaymentMode.id_for(:cash)
      if self.destination_pocket_id.blank?
        errors.add(:cash, "money requests cannot be created without a destination account")
      end
    end
  end

  private
  def handle_name
    if self.name.blank?
      self.name = MoneyRequest.get_default_name(self.user)
    end
  end

  def handle_nil_amount
    self.items.each do |item|
      if item.amount.value == nil
        item.amount.value = 0
      end
    end
  end

  def create_items
    return unless self.items.blank?
    self.user.company.money_request_item_categories.active.each do |category|
      amount = Amount.new(value: 0, currency_id: Currency.first.id)
      self.items.build money_request_item_category_id: category.id, amount: amount
    end
  end
end

# == Schema Information
#
# Table name: money_requests
#
#  id                           :integer          not null, primary key
#  name                         :string(255)
#  user_id                      :integer          not null
#  policy_id                    :integer
#  payment_mode_id              :integer          not null
#  payment_id                   :integer
#  required_by_date             :date
#  status_id                    :integer          not null
#  controlling_user_id          :integer
#  controlling_user_role_id     :integer
#  controlling_for_user_id      :integer
#  controlling_for_user_role_id :integer
#  loaded_by                    :integer
#  loaded_at                    :datetime
#  submitted_at                 :datetime
#  memo                         :string(255)
#  accounted                    :boolean          default(FALSE), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  is_deleted                   :boolean          default(FALSE), not null
#



class MoneyRequest < ActiveRecord::Base
  include OperationCallbacks, MathUtil, SoftDeletable

  belongs_to :status, class_name: 'MoneyRequestStatus'
  belongs_to :user
  belongs_to :card
  belongs_to :loaded_by, class_name: 'User'
  belongs_to :controlling_user, class_name: 'User'
  belongs_to :controlling_user_role, class_name: 'UserRole'
  belongs_to :controlling_for_user, class_name: 'User'
  belongs_to :controlling_for_user_role, class_name: 'UserRole'
  belongs_to :payment_mode
  belongs_to :status, class_name: 'MoneyRequestStatus'
  belongs_to :policy
  belongs_to :payment

  has_many :tracks, class_name: 'MoneyRequestTrack', foreign_key: :money_request_id, dependent: :destroy
  has_many :comments, class_name: 'MoneyRequestComment', foreign_key: :money_request_id, dependent: :destroy
  has_many :items, class_name: 'MoneyRequestItem', foreign_key: :money_request_id, dependent: :destroy

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

  scope :filter_status, ->(status_id) { where status_id: status_id }
  scope :filter_user_id, ->(id) { where(user_id: id) }
  scope :filter_request_id, ->(id) { where(id: id) }
  scope :filter_search, ->(value) do
    user_ids = self.pluck(:id)
    user_ids = User.with_id(user_ids).where("name like :value OR email like :value", value: "%#{value}%").pluck(:id)
    money_requests = arel_table
    where(money_requests[:name].matches("%#{value}%").or(money_requests[:user_id].in(user_ids)).or(money_requests[:id].eq(value)))
  end
  scope :filter_date, ->(date_from = nil, date_to = nil) do
    # sample params: filter_date[expense, 2016-03-01, 2016-03-20]
    unless date_from.blank? && date_to.blank?
      date_from = "1990-01-01" if date_from.blank?
      date_to = "2100-01-01" if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      # date_to = Date.today if date_to.blank?
      money_requests = arel_table
      where(money_requests[:created_at].gteq(date_from).and(money_requests[:created_at].lteq(date_to)))
    end
  end
  scope :filter_policy, -> (policy_id) { where(policy_id: policy_id) }

  accepts_nested_attributes_for :items
  delegate :status_name, to: :status
  delegate :payment_mode_name, to: :payment_mode

  default_scope { order(created_at: :desc, status_id: :asc) }

  before_save :handle_name
  before_save :handle_nil_amount
  before_create :create_items

  # Used to retrieve all the users associated with this money request. If user before is provided,
  # it provides a list of all users who interacted with the money request before this given user. Mainly used for reject_to
  def associated_users(user_before = nil, ordered = false)
    return nil if tracks.blank?
    trackings = tracks.without_take_control_action
    if user_before.present?
      track = trackings.with_action_user(user_before.id).first
      unless track.blank?
        trackings = trackings.created_before(track.created_at)
      end
    end
    user_ids = trackings.map(&:action_user_id).uniq
    if controlling_user_id.present? and (user_before.blank? or user_before.id != controlling_user_id)
      if controlling_for_user_id.present?
        user_ids << controlling_for_user_id
      else
        user_ids << controlling_user_id
      end
    end
    if user_ids.size > 0
      # Order is MySQL Specific
      user_ids = user_ids.reverse!
      user_ids.reject! { |id| id.blank? }
      return User.where(id: user_ids).where(company_id: self.user.company_id).order("field(id,#{user_ids.join(',')})")
    end
    nil
  end

  def open?
    status_id == MoneyRequestStatus.open_id
  end

  def processing?
    status_id == MoneyRequestStatus.processing_id
  end

  def retracted?
    status_id == MoneyRequestStatus.retracted_id
  end

  def rejected?
    status_id == MoneyRequestStatus.rejected_id
  end

  def approved?
    status_id == MoneyRequestStatus.approved_id
  end

  def credited?
    status_id == MoneyRequestStatus.credited_id
  end

  def can_submit?
    open? or retracted? or rejected?
  end

  def can_retract?
    processing?
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
    if self.submitted_at.present?
      if self.policy
        return self.policy.version_at self.submitted_at, has_many: true, has_one: true, belongs_to: true
      end
    end
    self.policy
  end

  def final_approver
    return nil unless self.approved? or self.credited?
    tracks = self.tracks.with_action(MoneyRequestTrackingAction.approve_id)
    if tracks.present?
      return tracks.last.action_user
    end
    nil
  end

  def self.get_default_name(user)
    "#{user.name.downcase.split.join('_')}_#{Time.now.strftime("%d.%m.%y")}"
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
    self.user.company.active_categories.each do |category|
      amount = Amount.create value: 0, currency_id: Currency.first.id
      self.items.build category_id: category.id, amount_id: amount.id
    end
  end

end

# == Schema Information
#
# Table name: travel_requests
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  policy_id                    :integer
#  name                         :string(255)
#  note                         :text(65535)
#  status_id                    :integer          not null
#  controlling_user_id          :integer
#  controlling_user_role_id     :integer
#  controlling_for_user_id      :integer
#  controlling_for_user_role_id :integer
#  submitted_at                 :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  company_id                   :integer
#  is_deleted                   :boolean          default(FALSE)
#  rejection_note               :text(65535)
#  auto_approved                :boolean
#  memo                         :text(65535)
#  from_date                    :date
#  to_date                      :date
#  trip_id                      :string(255)
#  purpose_of_travel            :text(65535)
#  approved_at                  :datetime
#  selection_requested_at       :datetime
#  booking_confirmed_at         :datetime
#  controlling_level_id         :integer
#  created_by_id                :integer
#  modified_by_id               :integer
#

class TravelRequest < ActiveRecord::Base
  include SoftDeletable,
          Sequenced::ActsAsSequenced,
          FieldCustomizer::CustomizableValidation,
          FindByOrderedIds,
          Transitionable


  acts_as_sequenced column: :trip_id, purpose: :travel_request, editable: false, prefix: 'TR-'

  field_customization_key :travel_request
  customizable_validate :from_date, presence: true
  customizable_validate :to_date, presence: true
  customizable_validate :purpose_of_travel, presence: false

  belongs_to :user
  belongs_to :policy
  belongs_to :status, class_name: 'TravelRequestStatus'
  has_many :reports
  has_many :money_requests
  has_many :bookings

  belongs_to :controlling_user, class_name: 'User'
  belongs_to :controlling_user_role, class_name: 'UserRole'
  belongs_to :controlling_for_user, class_name: 'User'
  belongs_to :controlling_for_user_role, class_name: 'UserRole'
  belongs_to :company

  has_many :destinations, class_name: 'TravelRequestDestination'
  has_many :travel_request_trails, dependent: :destroy
  has_many :comments, class_name: 'TravelRequestComment', dependent: :destroy
  has_many :custom_fields, as: :parent, dependent: :destroy

  accepts_nested_attributes_for :destinations, allow_destroy: true
  accepts_nested_attributes_for :custom_fields, allow_destroy: true

  delegate :open?, :processing?, :approved?, :booked?, :booking_pending?, :rejected?, :retracted?,
           :selection_requested?, :selection_processing?, :selection_rejected?, :selection_confirmed?, :booking_confirmed?, to: :status

  validates :status_id, presence: true #, unless: :open?
  validates :policy, presence: true
  validates :user_id, presence: true #, unless: :open?
  #validates :name, presence: true#, unless: :open?
  # validates :from_date, presence: true
  # validates :to_date, presence: true
  validate :acceptable_dates?

  # default_scope {order(status_id: :asc, submitted_at: :desc, created_at: :desc)}

  scope :with_id, ->(id) {where id: id}
  scope :not_open, -> {where.not(status_id: TravelRequestStatus.id_for(:open))}
  scope :non_owner, -> (user_id) {where.not user_id: user_id}
  scope :open, -> {where(status_id: TravelRequestStatus.id_for(:open))}
  scope :approved, -> {where(status_id: TravelRequestStatus.id_for(:approved))}
  scope :processing, -> {where(status_id: TravelRequestStatus.id_for(:processing))}
  scope :with_status_id, ->(id) {where status_id: id}
  scope :with_user, -> (user_id) {where user_id: user_id}
  scope :with_policy, -> (policy_id) {where policy_id: policy_id}
  scope :with_controlling_user_role_id, -> (role_id) {where controlling_user_role_id: role_id}
  scope :with_controlling_user_id, -> (user_id) {where controlling_user_id: user_id}
  scope :filter_user_id, -> (id) {where user_id: id}
  scope :sort_for_manager, -> {order(status_id: :asc, submitted_at: :desc, created_at: :desc)}
  scope :sort_for_personal, -> {order(created_at: :desc)}
  scope :money_requestable, -> { where('to_date >= ?', Date.today).where(status_id: TravelRequestStatus.id_for(:booking_confirmed)) }
  scope :reportable, -> { where(status_id: TravelRequestStatus.id_for(:booking_confirmed)) }
  scope :filter_date, ->(date_from = nil, date_to = nil) do
    # sample params: filter_date[expense, 2016-03-01, 2016-03-20]
    unless date_from.blank? && date_to.blank?
      date_from = "1990-01-01" if date_from.blank?
      date_to = "2100-01-01" if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      # date_to = DateUtils.local_date if date_to.blank?
      where.not 'from_date >= ? OR to_date <= ?', date_to, date_from
    end
  end
  scope :filter_status, -> (status) do
    case status&.to_sym
    when :retracted
      with_status_id TravelRequestStatus.ids_for(:open, :processing, :retracted, :rejected)
    when :processing
      with_status_id TravelRequestStatus.ids_for(:processing)
    when :booking_pending
      with_status_id TravelRequestStatus.ids_for(
          :booking_pending,
          :selection_requested,
          :selection_processing,
          :selection_confirmed,
          :selection_rejected
      )
    when :booking_confirmed
      with_status_id TravelRequestStatus.ids_for(:booking_confirmed)
    when :cancelled
      with_status_id TravelRequestStatus.ids_for(:cancelled)
    when :rejected
      with_status_id TravelRequestStatus.ids_for(:rejected)
    when :selection_in_progress
      with_status_id TravelRequestStatus.ids_for(:selection_requested, :selection_processing, :selection_confirmed, :selection_rejected)
    end
  end
  scope :order_by_controlling_user, ->(user_id, manager=false) {
    if user_id.present?
      ids = pluck(:id)
      controlling_money_requests = where(controlling_user_id: user_id)
      if manager
        controlling_money_requests = controlling_money_requests.where(status_id: TravelRequestStatus.ids_for(:processing, :booking_pending,
                                                                                                             :selection_requested, :selection_processing,
                                                                                                             :selection_confirmed))
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

  def can_submit?
    open? || retracted? || rejected?
  end

  def can_approve?
    processing?
  end

  def can_reject?
    processing?
  end

  def can_retract?
    processing? || auto_approved?
  end

  def can_take_control?
    processing?
  end

  def can_finish_booking?
    approved? or booking_pending?
  end

  def can_retract_booking?
    booked?
  end

  def can_destroy?
    open? or retracted? or rejected?
  end

  def destinations_list
    names = []
    self.destinations.each do |destination|
      name = destination&.location&.name
      names << name if name.present?
    end
    names
  end

  def summary
    s = {}
    trip_cost = 0
    base_currency = policy.base_currency
    zero_amount = Amount.new value: 0, currency: base_currency
    s[:money_request_processed] = money_request_processed || zero_amount
    s[:expense_claims_submitted] = expense_claims_submitted || zero_amount
    s[:booking_cost] = booking_cost || zero_amount
    trip_cost += s[:money_request_processed].value
    trip_cost += s[:expense_claims_submitted].value
    trip_cost += s[:booking_cost].value
    s[:trip_cost] = Amount.new value: trip_cost, currency: base_currency
    s
    # money_requests_processed
    # expense_claims_submitted
    # booking_cost
    # Trip Cost
  end

  def money_request_processed
    return nil unless money_requests.present?
    total = 0
    money_requests.each do |money_request|
      total += money_request.total_amount
    end
    return nil unless total > 0
    currency = money_requests.first.base_currency
    Amount.new value: total, currency: currency
  end

  def expense_claims_submitted
    return nil unless reports.present?
    expenses = Expense.with_report_id(reports.pluck(:id))
    amounts = Amount.with_id(expenses.pluck(:amount_id))
    total = amounts.sum(policy.base_currency.country_code.to_sym)
    return nil if total == 0
    currency = policy.base_currency
    Amount.new value: total, currency: currency
  end

  def booking_cost
    return nil if bookings.blank?
    confirmed_bookings = Booking.with_travel_request_id(id).confirmed
    confirmed_booking_ids = confirmed_bookings.pluck(:id)
    value = BookingFlight.with_parent_booking_id(confirmed_booking_ids).sum_cost +
        BookingTrain.with_parent_booking_id(confirmed_booking_ids).sum_cost +
        BookingBus.with_parent_booking_id(confirmed_booking_ids).sum_cost +
        BookingHotel.with_parent_booking_id(confirmed_booking_ids).sum_cost +
        BookingCarRental.with_parent_booking_id(confirmed_booking_ids).sum_cost
    currency = Currency.first
    Amount.new value: value, currency: currency
  end

  def controlling_user?(user)
    return false if self.controlling_user.blank?
    self.controlling_user.id == user.id
  end

  def status_for_user(user)
    return status.name unless controlling_user?(user)
    if processing?
      return 'awaiting_approval'
    elsif selection_requested?
      return 'awaiting_selection'
    elsif selection_processing?
      return 'awaiting_selection_approval'
    elsif booking_pending? or selection_confirmed?
      return 'awaiting_booking'
    end
    status.name
  end


  def as_json(options = {})
    {
        id: id,
        trip_id: trip_id,
        name: name,
        purpose_of_travel: purpose_of_travel,
        policy: policy,
        status: status,
        user: user,
        controlling_user: controlling_user,
        dates: {
            from: DateUtils.date_formatted(from_date),
            to: DateUtils.date_formatted(to_date)
        },
        destinations: destinations,
        destinations_list: destinations_list,
        summary: summary
    }
  end

  def self.status_ids(*statuses)
    status_ids = []
    statuses.each do |status|
      status_ids.push TravelRequestStatus.id_for(status)
    end

    status_ids.reject { |status_id| status_id.nil? }
  end

  protected

  def acceptable_dates?
    return if from_date.blank?
    return if to_date.blank?
    unless from_date <= to_date
      errors.add :from_date, 'cannot be after to date'
    end
  end

  def self.document_owner_attribute
    'user_id'
  end

end

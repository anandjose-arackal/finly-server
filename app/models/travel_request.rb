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
#

class TravelRequest < ActiveRecord::Base
  include SoftDeletable, Sequenced::ActsAsSequenced

  acts_as_sequenced column: :trip_id, purpose: :travel_request, editable: false

  belongs_to :user
  belongs_to :policy
  belongs_to :status, class_name: 'TravelRequestStatus'
  has_many :reports
  has_many :money_requests

  belongs_to :controlling_user, class_name: 'User'
  belongs_to :controlling_user_role, class_name: 'UserRole'
  belongs_to :controlling_for_user, class_name: 'User'
  belongs_to :controlling_for_user_role, class_name: 'UserRole'

  has_many :destinations, class_name: 'TravelRequestDestination'
  has_many :travel_request_trails, dependent: :destroy
  has_many :comments, class_name: 'TravelRequestComment', dependent: :destroy

  accepts_nested_attributes_for :destinations, allow_destroy: true

  delegate :open?, :processing?, :approved?, :booked?, :booking_pending?, :rejected?, :retracted?,
           :selection_requested?, :selection_processing?, :selection_confirmed?, :booking_confirmed?, to: :status

  validates :status_id, presence: true#, unless: :open?
  validates :user_id, presence: true#, unless: :open?
  validates :name, presence: true#, unless: :open?

  default_scope { order(status_id: :asc, submitted_at: :desc, created_at: :desc) }

  scope :with_id, ->(id) {where id: id}
  scope :not_open, -> { where.not(status_id: TravelRequestStatus.id_for(:open)) }
  scope :non_owner, -> (user_id) {where.not user_id: user_id}
  scope :open, -> { where(status_id: TravelRequestStatus.id_for(:open)) }
  scope :approved, -> { where(status_id: TravelRequestStatus.id_for(:approved)) }
  scope :processing, -> { where(status_id: TravelRequestStatus.id_for(:processing)) }
  scope :with_user, -> (user_id) { where user_id: user_id }
  scope :with_policy, -> (policy_id) { where policy_id: policy_id }
  scope :with_controlling_user_role_id, -> (role_id) { where controlling_user_role_id: role_id }
  scope :with_controlling_user_id, -> (user_id) { where controlling_user_id: user_id }


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
      names << destination.location.name
    end
    names
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
        destinations_list: destinations_list
    }
  end

end

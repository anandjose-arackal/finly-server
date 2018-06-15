# == Schema Information
#
# Table name: travel_requests
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  policy_id                    :integer
#  name                         :string(255)
#  required_by_date             :date
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
#  report_id                    :integer
#  money_request_id             :integer
#

class TravelRequest < ActiveRecord::Base

  include SoftDeletable

  belongs_to :user
  belongs_to :policy
  belongs_to :status, class_name: "TravelRequestStatus"
  has_one :report

  belongs_to :controlling_user, class_name: 'User'
  belongs_to :controlling_user_role, class_name: 'UserRole'
  belongs_to :controlling_for_user, class_name: 'User'
  belongs_to :controlling_for_user_role, class_name: 'UserRole'

  has_many :destinations, class_name: "TravelRequestDestination"
  has_many :travel_request_trails
  has_many :comments, class_name: "TravelRequestComment"

  accepts_nested_attributes_for :destinations, allow_destroy: true

  delegate :open?, :processing?, :approved?, :booked?, :booking_pending?, :rejected?, :retracted?, to: :status

  validates :status_id, presence: true, unless: :open?
  validates :user_id, presence: true, unless: :open?
  validates :name, presence: true, unless: :open?

  scope :with_id, ->(id) { where id: id }
  scope :not_open, -> {
    where.not(status_id: TravelRequestStatus.id_for(:open))
  }

  scope :non_owner, -> (user_id) { where.not user_id: user_id }

  scope :open, -> {
    where(status_id: TravelRequestStatus.id_for(:open))
  }

  scope :approved, -> {
    where(status_id: TravelRequestStatus.id_for(:approved))
  }

  scope :processing, -> {
    where(status_id: TravelRequestStatus.id_for(:processing))
  }

  scope :with_user, -> (user_id) {
    where user_id: user_id
  }

  scope :with_policy, -> (policy_id) {
    where policy_id: policy_id
  }

  scope :with_controlling_user_role_id, -> (role_id) {
    where controlling_user_role_id: role_id
  }
  scope :with_controlling_user_id, -> (user_id) {
    where controlling_user_id: user_id
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

  private

end

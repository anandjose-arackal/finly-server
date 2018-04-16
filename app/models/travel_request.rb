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
#

class TravelRequest < ActiveRecord::Base

  belongs_to :user
  belongs_to :policy
  belongs_to :status, class_name: "TravelRequestStatus"

  belongs_to :controlling_user, class_name: 'User'
  belongs_to :controlling_user_role, class_name: 'UserRole'
  belongs_to :controlling_for_user, class_name: 'User'
  belongs_to :controlling_for_user_role, class_name: 'UserRole'

  has_many :destinations, class_name: "TravelRequestDestination"

  accepts_nested_attributes_for :destinations

  delegate :open?, :processing?, :approved?, to: :status

  validates :status_id, presence: true
  validates :user_id, presence: true
  validates :name, presence: true
end

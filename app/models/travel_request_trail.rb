# == Schema Information
#
# Table name: travel_request_trails
#
#  id                       :integer          not null, primary key
#  travel_request_id        :integer
#  action_id                :integer
#  action_user_id           :integer
#  action_user_role_id      :integer
#  modified_user_id         :integer
#  modified_user_role_id    :integer
#  action_for_user_id       :integer
#  action_for_user_role_id  :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  is_deleted               :boolean          default(FALSE)
#  delegated_action_user_id :integer
#  deleted_at               :datetime
#

class TravelRequestTrail < ActiveRecord::Base
  include SoftDeletable

  belongs_to :travel_request
  belongs_to :action, class_name: "TravelRequestTrailAction"
  belongs_to :action_user, class_name: "User"
  belongs_to :modified_user, class_name: "User"
  belongs_to :action_for_user, class_name: "User"

  belongs_to :action_user_role, class_name: "UserRole"
  belongs_to :modified_user_role, class_name: "UserRole"
  belongs_to :modified_user_role, class_name: "UserRole"

  scope :manager_role, -> { where('modified_user_role_id = ?', "#{UserRole.id_for(:manager)}") }
  scope :travel_manager_role, -> { where('modified_user_role_id = ?', "#{UserRole.id_for(:travel_manager)}") }
  scope :involving_user, -> (user_id) { where('modified_user_id = ? OR action_user_id = ?', user_id, user_id) }
  scope :created_before, -> (created_before) {where 'created_at < ?', created_before}
  scope :with_action, -> (action_id) { where action_id: action_id }

end

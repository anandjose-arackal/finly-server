# == Schema Information
#
# Table name: trails
#
#  id                  :integer          not null, primary key
#  parent_id           :integer
#  parent_type         :string(255)
#  action_user_id      :integer
#  action_id           :integer
#  action_user_role_id :integer
#  action_level_id     :integer
#  modified_level_id   :integer
#  note                :text(65535)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Trail < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  belongs_to :action, class_name: 'TrailAction'
  belongs_to :action_user, class_name: 'User'
  belongs_to :action_user_role, class_name: 'UserRole'
  belongs_to :action_level, class_name: 'ReviewalLevel'
  belongs_to :modified_level, class_name: 'ReviewalLevel'


  scope :created_before, -> (time) { where 'created_at < ?', time }
end

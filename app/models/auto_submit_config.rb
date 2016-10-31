# == Schema Information
#
# Table name: auto_submit_configs
#
#  id                  :integer          not null, primary key
#  enabled             :boolean          default(FALSE), not null
#  period_id           :integer          not null
#  default_note        :text(65535)
#  default_category_id :integer          not null
#  default_policy_id   :integer
#  submitable_id       :integer
#  submitable_type     :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class AutoSubmitConfig < ActiveRecord::Base
  belongs_to :period
  belongs_to :submitable, polymorphic: true
  belongs_to :default_category, class_name: 'Category'
  belongs_to :default_policy, class_name: 'Policy'

  validates :period_id, presence: true
  validates :submitable_id, presence: true
  validates :submitable_type, presence: true
  validates :default_category_id, presence: true
  validates :enabled, :inclusion => { :in => [true, false] }
end
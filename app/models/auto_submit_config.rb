# == Schema Information
#
# Table name: auto_submit_configs
#
#  id                     :integer          not null, primary key
#  enabled                :boolean          default(FALSE), not null
#  limit_to_card_expenses :boolean          default(FALSE), not null
#  period_id              :integer          not null
#  default_memo           :text(65535)
#  default_policy_id      :integer
#  submitable_id          :integer          not null
#  submitable_type        :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class AutoSubmitConfig < ActiveRecord::Base
  belongs_to :period
  belongs_to :submitable, polymorphic: true
  belongs_to :default_policy, class_name: 'Policy'

  validates :period_id, presence: true
  validates :submitable_id, presence: true
  validates :submitable_type, presence: true
  validates :enabled, :inclusion => { :in => [true, false] }
end

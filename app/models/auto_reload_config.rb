# == Schema Information
#
# Table name: auto_reload_configs
#
#  id                 :integer          not null, primary key
#  minimum_balance_id :integer
#  parent_id          :integer
#  parent_type        :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  enabled            :boolean          default(FALSE)
#

class AutoReloadConfig < ActiveRecord::Base

  belongs_to :reloadable, polymorphic: true
  belongs_to :minimum_balance, class_name: 'Amount'

  accepts_nested_attributes_for :minimum_balance

  delegate :minimum_balance_value, to: :minimum_balance

  validate :minimum_balance_presence

  private

  def minimum_balance_presence
    if self.enabled
      unless minimum_balance.present?
        errors.add(:minimum_balance, "cannot be blank")
      end
    end
  end
end

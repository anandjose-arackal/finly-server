# == Schema Information
#
# Table name: cards
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  ending_number       :string(255)      not null
#  proxy               :string(255)      not null
#  card_type_id        :integer
#  description         :text(65535)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :integer
#  disabled_by_role_id :integer
#  active              :boolean
#

class Card < ActiveRecord::Base
  belongs_to :card_type
  belongs_to :user
  belongs_to :company
  belongs_to :disabled_by_role, class_name: "UserRole"

  scope :with_id, ->(id) { where id: id }
  scope :with_user, ->(user_id) { where user_id: user_id }
  scope :unassigned, -> {where user_id: nil}
  scope :active, -> {where active: true}

  def serial_id
    self.proxy
  end

end

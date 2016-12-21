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
#  disabled_by_user_id :integer
#  active              :boolean
#  disable_note        :text(65535)
#  product_code        :string(255)      not null
#

class Card < ActiveRecord::Base
  belongs_to :card_type
  belongs_to :user
  belongs_to :company
  belongs_to :disabled_by_role, class_name: 'UserRole'
  belongs_to :disabled_by_user, class_name: 'User'
  has_many :transactions, class_name: 'CardTransaction'


  scope :with_id, ->(id) { where id: id }
  scope :with_user, ->(user_id) { where user_id: user_id }
  scope :unassigned, -> {where user_id: nil}
  scope :active, -> {where active: true}

  validates :proxy, uniqueness: true

  # before_save do
  #   if self.proxy
  #     self.ending_number = proxy.last(4)
  #   else
  #     self.ending_number = ""
  #   end
  # end

  attr_accessor :balance, :available_card_eligibility

  def serial_id
    self.proxy
  end

end

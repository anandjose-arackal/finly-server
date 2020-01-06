# == Schema Information
#
# Table name: addresses
#
#  id           :integer          not null, primary key
#  line_1       :text(65535)
#  line_2       :text(65535)
#  line_3       :text(65535)
#  city         :string(255)
#  state_id     :integer
#  name         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  pin_code     :string(255)
#  default      :boolean
#  parent_type  :string(255)
#  parent_id    :integer
#  address_name :string(255)
#  landmark     :text(65535)
#

class Address < ApplicationRecord
  belongs_to :state, optional: true, class_name: "GstStateCode"
  belongs_to :parent, optional: true, polymorphic: true

  # validates :pin_code, presence: true
  # validates :name, presence: true
  validates :address_name, presence: true
  validates :city, presence: true

  scope :default, -> { where default: true }
end

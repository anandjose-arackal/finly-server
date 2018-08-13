# == Schema Information
#
# Table name: locations
#
#  id             :integer          not null, primary key
#  locatable_id   :integer
#  locatable_type :string(255)
#  latitude       :decimal(30, 15)
#  longitude      :decimal(30, 15)
#  name           :string(255)
#  address        :text(65535)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  order          :integer
#  maps_id        :string(255)
#

class Location < ActiveRecord::Base

  belongs_to :locatable, polymorphic: true

  default_scope { order(order: :asc) }

  validates :order, presence: true

  scope :with_id, -> (id) { where id: id }
  scope :with_order, -> (order){ where order: order }

end

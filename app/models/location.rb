# == Schema Information
#
# Table name: locations
#
#  id             :integer          not null, primary key
#  locatable_id   :integer
#  locatable_type :string(255)
#  latitude       :decimal(10, )
#  longitude      :decimal(10, )
#  name           :string(255)
#  address        :text(65535)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Location < ActiveRecord::Base

  belongs_to :locatable, polymorphic: true

  default_scope { order(order: :asc) }

  validates :order, presence: true

  scope :with_id, -> (id) { where id: id }
  scope :with_order, -> (order){ where order: order }

end

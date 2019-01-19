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
#  is_deleted     :boolean          default(FALSE)
#  deleted_at     :datetime
#

class Location < ActiveRecord::Base
  include SoftDeletable

  belongs_to :locatable, polymorphic: true

  default_scope { order(order: :asc) }

  # validates :order, presence: true

  scope :with_id, -> (id) { where id: id }
  scope :with_order, -> (order){ where order: order }

  validates :name, presence: true

  def as_json(options={})
    {
        id: id,
        latitude: latitude,
        longitude: longitude,
        name: name,
        address: address,
        maps_id: maps_id,
        order: order
    }
  end

end

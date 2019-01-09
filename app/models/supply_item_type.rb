# == Schema Information
#
# Table name: supply_item_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class SupplyItemType < ActiveRecord::Base
  include Seedable

  def self.values
    [:po_item, :non_po_item]
  end

  def non_po_item?
    self.id == SupplyItemType.id_for(:non_po_item)
  end

  def po_item?
    self.id == SupplyItemType.id_for(:po_item)
  end

  def as_json
    {
        id: id,
        name: name.humanize.split(" ").map(&:capitalize).join(" ")
    }
  end
end

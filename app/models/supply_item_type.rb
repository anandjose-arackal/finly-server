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

class SupplyItemType < ApplicationRecord
  include Seedable

  def self.values
    [:po_item, :non_po_item, :po_non_po_item]
  end

  def non_po_item?
    self.id == SupplyItemType.id_for(:non_po_item)
  end

  def po_item?
    self.id == SupplyItemType.id_for(:po_item)
  end

  def as_json
    data = {
        id: id,
        name: name.humanize.split(" ").map(&:capitalize).join(" ")
    }

    if id == SupplyItemType.id_for(:po_non_po_item)
      data[:name] = "PO / Non PO Item"
    end

    data
  end
end

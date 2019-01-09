# == Schema Information
#
# Table name: field_parent_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldParentType < ActiveRecord::Base

  TYPES = {
      report: 1,
      money_request: 2,
      manual_expense: 3,
      time_expense: 4,
      distance_expense: 5,
      per_diem_expense: 6,
      card_expense: 7,
      invoice: 8,
      invoice_line_item: 9,
      outward_invoice: 10,
      outward_invoice_line_item: 11,
      purchase_order: 12,
      inventory_line_item: 13,
      purchase_order_item: 14,
      travel_request: 15,
      booking_request: 16,
      vendor: 17
  }

  scope :with_name, -> (name) { where name: name }
  def self.id_for(sym)
    TYPES[sym]
  end

  def self.seed_data
    c = self.count
    TYPES.each do |name, id|
      if c == 0 or self.with_name(name).blank?
        self.create name: name
      end
    end
  end

  def self.expense_ids
    [FieldParentType.id_for(:manual_expense), FieldParentType.id_for(:card_expense),
     FieldParentType.id_for(:time_expense), FieldParentType.id_for(:distance_expense),
     FieldParentType.id_for(:per_diem_expense)]
  end

  def as_json(options={})
    n = name&.humanize
    if name == 'manual_expense'
      n = 'Cash Expense'
    end
    {
        id: id,
        name: n
    }
  end


end

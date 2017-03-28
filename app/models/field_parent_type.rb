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

  TYPES = {report: 1,
           money_request: 2,
           manual_expense: 3,
           time_expense: 4,
           distance_expense: 5,
           per_diem_expense: 6}

  def self.id_for(sym)
    TYPES[sym]
  end

  def self.expense_ids
    [FieldParentType.id_for(:manual_expense), FieldParentType.id_for(:time_expense),
     FieldParentType.id_for(:distance_expense), FieldParentType.id_for(:per_diem_expense)]
  end

end

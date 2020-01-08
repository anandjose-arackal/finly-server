# == Schema Information
#
# Table name: expense_tax_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExpenseTaxType < ApplicationRecord
  include Seedable

  def self.values
    [:none, :gst, :tds, :gst_tds]
  end

end

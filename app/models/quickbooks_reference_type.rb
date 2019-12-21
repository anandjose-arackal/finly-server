# == Schema Information
#
# Table name: quickbooks_reference_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class QuickbooksReferenceType < ApplicationRecord
  include Seedable

  def self.values
    [:department]
  end

end

# == Schema Information
#
# Table name: mapping_purposes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MappingPurpose < ActiveRecord::Base

  include Seedable

  def self.values
    [:expense_management, :vendor_payments]
  end
end

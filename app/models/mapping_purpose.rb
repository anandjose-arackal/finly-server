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
    [:expense_management, :vendor_payments, :invoicing]
  end

  def self.id_from_application_for(application)
    case application
      when :vp, 'vp'
        return MappingPurpose.id_for(:vendor_payments)
      when 'em', :em, :ft, 'ft'
        return MappingPurpose.id_for(:expense_management)
      else
        # do nothing?
    end
  end
end

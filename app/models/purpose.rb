# == Schema Information
#
# Table name: purposes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Purpose < ActiveRecord::Base

  include Seedable

  def self.values
    [:expense_management, :vendor_payments]
  end

  def self.id_from_application_for(application)
    case application
      when :vp, 'vp'
        return Purpose.id_for(:vendor_payments)
      when 'em', :em, :ft, 'ft'
        return Purpose.id_for(:expense_management)
      else
        # do nothing?
    end
  end
end

# == Schema Information
#
# Table name: purposes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Purpose < ApplicationRecord

  include Seedable

  def self.values
    [
        :expense_management, :vendor_payments, :invoice, :invoice_items, :outward_invoice,
        :outward_invoice_items, :collect, :travel_request, :report, :money_request, :procurement, :vendor,
        :grn, :item_master, :rate_contract
    ]
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

  def self.category_purpose_from_application(application)
    case application
    when :vp, 'vp'
      return [:vendor_payments, :inward_invoice_line_items]
    when 'em', :em, :ft, 'ft'
      return :expense_management
    when 'fc', :fc
      return :outward_invoice_line_items # because from the outward invoice system, only invoice items categories can be created
    else
      # do nothing?
    end
  end
end
# == Schema Information
#
# Table name: inward_invoice_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class InwardInvoiceStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:unpaid, :partially_paid, :paid]
  end

  def unpaid?
    self.id == InwardInvoiceStatus.id_for(:unpaid)
  end

  def partially_paid?
    self.id == InwardInvoiceStatus.id_for(:partially_paid)
  end

  def paid?
    self.id == InwardInvoiceStatus.id_for(:paid)
  end

end

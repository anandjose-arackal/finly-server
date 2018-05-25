# == Schema Information
#
# Table name: purchase_order_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PurchaseOrderStatus < ActiveRecord::Base
  include Seedable
  def self.values
    %w( saved released invoice_created received change_order cancelled closed )
  end

end

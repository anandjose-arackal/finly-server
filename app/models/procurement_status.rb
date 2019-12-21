# == Schema Information
#
# Table name: procurement_statuses
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ProcurementStatus < ApplicationRecord
  include Seedable
  def self.values
    %w( draft purchase_order_approved sent_to_vendor invoice_received payment_processing payment_processed receiving_shipment shipment_received closed cancelled vendor_confirmed)
  end
end

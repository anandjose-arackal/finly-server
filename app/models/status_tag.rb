# == Schema Information
#
# Table name: status_tags
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  display_name    :string(255)
#  description     :string(255)
#  font_icon       :string(255)
#  font_icon_color :string(255)
#  icon_path       :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class StatusTag < ApplicationRecord
  include Seedable
  def self.values
    [
        {name: "po_processing", display_name: "PO Processing", description: "Purchase Order is Being Processed", font_icon: "hourglass-half", font_icon_color: "#afa400", icon_path: ""},
        {name: "po_approved", display_name: "PO Approved", description: "Purchase Order has been Approved", font_icon: "check-circle", font_icon_color: "green", icon_path: ""},
        {name: "po_sent", display_name: "PO Sent", description: "Purchase Order Sent to Vendor", font_icon: "paper-plane", font_icon_color: "green", icon_path: ""},
        {name: "po_vendor_confirmed", display_name: "PO Vendor Confirmed", description: "Purchase Order Confirmed by Vendor", font_icon: "paper-plane", font_icon_color: "green", icon_path: ""},
        {name: "invoice_received", display_name: "Invoice Received", description: "Invoice Received from Vendor", font_icon: "arrow-circle-down", font_icon_color: "green", icon_path: ""},
        {name: "payment_processing", display_name: "Payment Processing", description: "Payment Being Processed", font_icon: "rupee", font_icon_color: "#afa400", icon_path: ""},
        {name: "payment_processed", display_name: "Payment Processed", description: "Payment Has Been Processed", font_icon: "rupee", font_icon_color: "green", icon_path: ""},
        {name: "receiving_shipment", display_name: "Receiving Shipment", description: "Shipment Received Partially", font_icon: "truck", font_icon_color: "#afa400", icon_path: ""},
        {name: "shipment_received", display_name: "Shipment Received", description: "All Shipment Has Been Received", font_icon: "truck", font_icon_color: "green", icon_path: ""},
        {name: "invoice_processing", display_name: "Invoice Processing", description: "Invoice is Being Processed", font_icon: "hourglass-half", font_icon_color: "#afa400", icon_path: ""},
        {name: "invoice_approved", display_name: "Invoice Approved", description: "Invoice has been Approved", font_icon: "check-circle", font_icon_color: "green", icon_path: ""}
    ]
  end

  scope :with_ids, -> (ids) {where id: ids}

  def self.seed_data
    p "Seeding #{self}"
    c = self.count
    self.values.each do |item|
      db_item = self.find_by(name: item[:name])
      if c == 0 or db_item.blank?
        self.create item
      else
        db_item.update item
      end
    end
  end
end

# == Schema Information
#
# Table name: export_resources
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  value      :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExportResource < ApplicationRecord
  RESOURCES = [
    {
      name: 'Invoice Line Items',
      value: 'invoice_line_items',
      route: 'invoices.index'
    },
    {
      name: 'Invoices',
      value: 'invoices',
      route: 'invoices.index'
    },
    {
      name: 'Payments',
      value: 'payments',
      route: 'payment_tickets.index'
    },
    {
      name: 'Purchase Requests',
      value: 'purchase_requests',
      route: 'purchase_requests.index'
    },
    {
      name: 'Purchase Orders',
      value: 'purchase_orders',
      route: 'purchase_orders.index'
    },
    {
      name: 'Purchase Order Items',
      value: 'purchase_order_items',
      route: 'purchase_orders.index'
    },
    {
      name: 'Users',
      value: 'users',
      route: 'user.index'
    },
    {
      name: 'Item Master',
      value: 'items',
      route: 'items.index'
    },
    {
      name: 'Vendors',
      value: 'vendors',
      route: 'vendors.index'
    },
    {
      name: 'Utility Bills',
      value: 'utility_bills',
      route: 'utility_bills.index'
    }
  ]

  def self.seed_data
    RESOURCES.each do |resource|
      next if ExportResource.find_by(value: resource[:value]).present?

      ExportResource.create(name: resource[:name], value: resource[:value], route: resource[:route])
    end
  end
end

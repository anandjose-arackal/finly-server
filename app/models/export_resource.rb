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
#  route      :string(255)
#

class ExportResource < ApplicationRecord
  RESOURCES = [
    {
      name: 'Invoice Line Items',
      value: 'invoice_line_items',
      resolver: 'invoice_line_items.default',
      route: 'invoices.index'
    },
    {
      name: 'Invoices',
      value: 'invoices',
      resolver: 'invoices.default',
      route: 'invoices.index'
    },
    {
      name: 'Payments',
      value: 'payments',
      resolver: 'payments.export',
      route: 'payment_ticket.index'
    },
    {
      name: 'Purchase Requests',
      value: 'purchase_requests',
      resolver: 'purchase_requests.default',
      route: 'purchase_requests.index'
    },
    {
      name: 'Purchase Orders',
      value: 'purchase_orders',
      resolver: 'purchase_orders.default',
      route: 'purchase_orders.index'
    },
    {
      name: 'Purchase Order Items',
      value: 'purchase_order_items',
      resolver: 'purchase_order_items.default',
      route: 'purchase_orders.index'
    },
    {
      name: 'Users',
      value: 'users',
      resolver: 'users.default',
      route: 'users.vp.index'
    },
    {
      name: 'Item Master',
      value: 'items',
      resolver: 'items.default',
      route: 'item_master.index'
    },
    {
      name: 'Vendors',
      value: 'vendors',
      resolver: 'vendors.default',
      route: 'vendors.index'
    },
    {
      name: 'Utility Bills',
      value: 'utility_bills',
      resolver: 'utility_bills.default',
      route: 'utility_bills.index'
    },
    {
      name: 'Utility Subscriptions',
      value: 'utility_subscriptions',
      resolver: 'utility_subscriptions.default',
      route: 'utility_subscriptions.index'
    }
  ]

  def self.seed_data
    RESOURCES.each do |resource|
      if ExportResource.find_by(value: resource[:value]).present?
        export_resource = ExportResource.find_by(value: resource[:value])
        export_resource.update_columns(name: resource[:name], value: resource[:value], route: resource[:route], resolver: resource[:resolver])
      else
        ExportResource.create(name: resource[:name], value: resource[:value], route: resource[:route], resolver: resource[:resolver])
      end
    end
  end
end

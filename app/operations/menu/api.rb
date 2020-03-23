class Menu::API
  include DynamicAttributes

  class_attr :app

  def self.items
    @items ||= []
  end

  def self.item(key, path: nil, icon: nil, label: nil, create: false, &block)
    items << Menu::Item.new(key: key, path: path, icon: icon, label: label, create: create, &block)
  end

  def as_json(options={})
    items.as_json
  end

  app :vp
  item :dashboard, path: 'dashboard', icon: "https://img.icons8.com/windows/22/ffffff/speed.png"
  item :request
  item :procure do
    item :purchase_orders
    item :pr_approved_items, path: 'po_approval_items'
  end
  item :receive do
    item :receive_pending
    item :receive_history
  end
  item :payables do
    item :po_advances
    item :invoices do
      item :po_invoices
      item :non_po_invoices, create: true
      item :agreement_invoices
      item :utility_bills
    end
    item :pending do
      item :upcoming_agreement_invoices
      item :unbilled_items
    end
    # item :payment_items # todo
  end
  item :payments do
    item :payment_tickets
    item :payments
  end
  item :manage do
    item :vendors, create: true
    item :item_master, create: true
    item :rate_contracts, create: true
    item :agreements, create: true
    item :credit_notes, create: true
    item :utility_subscriptions, create: true
    item :users, create: true
  end

end
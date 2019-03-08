class Procurements::PurchaseOrders::SendMail < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :email_options

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = PurchaseOrder.find_by id: purchase_order_id

    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
      return
    end

    self.email_options = {}

    self.email_options[:email_to] = self.purchase_order&.vendor&.email
    self.email_options[:email_subject] = "Purchase Order from #{user.company.name} - #{self.purchase_order.po_number}"
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end

    if self.email_options[:email_to].blank?
      add_message :error, "Vendor doesn't have an email address"
    end
  end

  def process
    ProcurementMailer.delay.send_purchase_order_mail(purchase_order, email_options, user)
  end

  def post_process
    add_message :success, "Purchase Order successfully sent to vendor"
  end
end
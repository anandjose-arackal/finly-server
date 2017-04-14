# Execute executes the payment order and is always executed in the background.
# It can only be executed directly from create or from crono
class Benefits::TaxBenefits::Execute < BackgroundOperation
  attr_accessor :payment_order

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or (params[:payment_order_id].blank? and params[:id].blank?)
      add_message :error, 'Order not found'
    end
  end

  def init
    id = (params[:payment_order_id] or params[:id])
    self.payment_order = user.company.payment_orders.find_by_id(id)
  end

  def validate
    if self.payment_order.blank?
      add_message :error, 'Order not found'
    end
  end

  def process
    self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:in_progress))
    self.payment_order.payments.each do |payment|
      validation = Payment::Validate.(user, payment)
      unless validation.success?
        validation.messages[:error].each do |message|
          payment.system_messages.create content: message, message_type_id: SystemMessageType.id_for(:error)
        end
        payment.update(payment_status_id: PaymentStatus.id_for(:failed))
      end


    end
  end

end

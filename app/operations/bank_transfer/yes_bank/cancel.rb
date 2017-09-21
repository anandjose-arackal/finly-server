class BankTransfer::YesBank::Cancel < BankTransfer::YesBank::Base
  attr_accessor :payment_order, :cancel_note

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:id].blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def init
    self.payment_order = BankTransfer::YesBank::Index.(user, params).payment_orders.with_id(params[:id]).first rescue nil
    self.cancel_note = params[:note]
  end

  def validate
    if self.payment_order.blank?
      add_message :error, 'Order not found'
      return
    end

    unless self.payment_order.scheduled?
      add_message :error, 'Order cannot be cancelled at this stage'
    end
  end

  def process
    if self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:cancelled))
      self.payment_order.payments.each do |payment|
        unless payment.in_progress?
          payment.update(payment_status_id: PaymentStatus.id_for(:cancelled))
        end
      end
    else
      add_message :error, self.payment_order.errors.full_messages
    end
  end

  def post_process
    # add a comment saying that it has been cancelled
    bank_payment_request = payment_order.bank_payment_request
    bank_payment_request.comments.create user_id: user.id,
                                         action_id: BankPaymentRequestCommentAction.id_for(:cancel),
                                         note: self.cancel_note
  end

  def success
    params[:payment_order] = self.payment_order
    BankTransfer::YesBank::Cancel::SuccessPresenter.new(user, params, messages)
  end

  class BankTransfer::YesBank::Cancel::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order

    def init
      self.payment_order = params[:payment_order]
    end
  end

end
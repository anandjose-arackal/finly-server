class PurchaseOrderMailer < ApplicationMailer
  def send_purchase_order_mail(user_id, params)
    params[:purchase_order] = purchase_order(params[:purchase_order_id])
    presenter = Event::EPurchaseOrder::Base::MailerPresenter.new(user(user_id), params)

    @data = presenter
    if presenter.success?
      mail to: presenter.to, subject: presenter.subject, template_name: 'template_purchase_order'
    end
  end

  def send_po_approval_mail(user_id, params)
    params[:purchase_order] = purchase_order(params[:purchase_order_id])
    presenter = Event::EPurchaseOrder::Base::MailerPresenter.new(user(user_id), params)

    @data = presenter
    if presenter.success?
      mail to: presenter.to, subject: presenter.subject, template_name: 'purchase_order_mail_approval'
    end
  end

  def user(user_id)
    run_without_tenant { User.find user_id }
  end

  def purchase_order(purchase_order_id)
    run_without_tenant { PurchaseOrder.find purchase_order_id }
  end
end

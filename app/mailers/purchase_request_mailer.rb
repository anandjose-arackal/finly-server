class PurchaseRequestMailer < ApplicationMailer
  def send_purchase_request_mail(user_id, params)
    params[:purchase_request] = purchase_request(params[:purchase_request_id])
    presenter = Event::EPurchaseRequest::Base::MailerPresenter.new(user(user_id), params)
    
    @data = presenter
    if presenter.success?
      mail to: presenter.to, subject: presenter.subject, template_name: 'template_purchase_request'
    end
  end

  def send_pr_approval_mail(user_id, params)
    params[:purchase_request] = purchase_request(params[:purchase_request_id])
    presenter = Event::EPurchaseRequest::Base::MailerPresenter.new(user(user_id), params)

    @data = presenter
    if presenter.success?
      mail to: presenter.to, subject: presenter.subject, template_name: 'purchase_request_mail_approval'
    end
  end

  def user(user_id)
    run_without_tenant { User.find user_id }
  end

  def purchase_request(purchase_request_id)
    run_without_tenant { PurchaseRequest.find purchase_request_id }    
  end
end
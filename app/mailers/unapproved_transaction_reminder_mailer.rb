class UnapprovedTransactionReminderMailer < ApplicationMailer
  
  def send_unapproved_transaction_mail(presenter)
    @data = presenter
    @pending_items_count = @data.pending_items_count
    
    @url  = if Rails.env.development?
              "http://localhost:3001/"
            elsif Rails.env.staging?
              ActionMailer::Base.default_url_options[:host]
            else
              "https://www.finly.io/"
            end
    
    if ready_to_send?
      mail to: presenter.to, subject: presenter.subject, template_name: 'template_unapproved_transaction'
    end
  end

  private

  def ready_to_send?
    @data.user.present? && @data.to.present? && @data.subject.present? && @pending_items_count.present?
  end
end

class BbpsReminderMailer < ApplicationMailer
  
  def send_bbps_reminder_mail(presenter)
    @data = presenter
    @host = if Rails.env.development?
              "http://localhost/"
            elsif Rails.env.staging?
              ActionMailer::Base.default_url_options[:host]
            else
              "https://www.finly.io/"
            end
    
    @host = @host.to_s + "/" if @host[-1] != "/" #adding slash if not present to make URL valid
    @url = @host + "payments#utility_bill/#{@data.payload[:bill_id]}/params={}"
    
    if ready_to_send?
      mail to: presenter.to, subject: presenter.subject, template_name: 'template_bbps_reminder'
    end
  end

  private

  def ready_to_send?
    @data.present? and
    @data.user.present? and
    @data.to.present? and
    @data.subject.present? and
    @data.payload.present?
  end
end

class TravelRequestMailer < ApplicationMailer

  def send_mail(presenter)
    if presenter.validate
      @data = presenter
      @current_user = @data.user
      @include_comments = false
      mail(to: presenter.to, subject: presenter.subject, template_name: 'template')
    end 
  end

end
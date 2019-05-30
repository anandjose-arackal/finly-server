class UserOtpMailer < ApplicationMailer

  def send_mail(presenter)

    @email = presenter.to
    @otp = presenter.otp
    @user_agent = presenter.user_agent
    @ip = presenter.ip
    @timestamp = presenter.timestamp

    location = Geocoder.search(presenter.ip)
    location = location.first if location.respond_to?(:each)
    data = location&.data
    loc_arr = []
    loc_arr << data&.dig('city', 'names', 'en')
    loc_arr << data&.dig('subdivisions')&.first&.dig('names', 'en')
    loc_arr << data&.dig('country', 'names', 'en')

    @approximate_location = loc_arr&.join(', ') unless loc_arr.blank?

    mail to: presenter.to, subject: presenter.subject, template_name: 'template'
  end

end
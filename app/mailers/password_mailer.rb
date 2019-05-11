class PasswordMailer < ApplicationMailer

  def notify_password_change(data)
    @email = data[:to]
    @user_agent = data[:user_agent]
    @ip = data[:ip]
    @timestamp = data[:timestamp]

    location = Geocoder.search(@ip)
    location = location.first if location.respond_to?(:each)
    data = location&.data
    loc_arr = []
    loc_arr << data&.dig('city', 'names', 'en')
    loc_arr << data&.dig('subdivisions')&.first&.dig('names', 'en')
    loc_arr << data&.dig('country', 'names', 'en')

    @approximate_location = loc_arr&.join(', ') unless loc_arr.blank?

    mail to: @email, subject: 'Finly password change confirmation'
  end

end

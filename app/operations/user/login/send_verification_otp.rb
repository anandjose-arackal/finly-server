class User::Login::SendVerificationOtp < BaseOperation

  include MathUtil

  attr_accessor :selected_user, :message, :otp, :otp_request_type_id

  OTP_RESEND_TIMER = Constants::OTP_RESEND_INTERVAL

  def self.call(params)
    super(nil, params)
  end

  def pre_validate
    if params.blank?
      add_message :error, "Please enter a mobile number"
    end
  end

  def init
    self.selected_user = User.find_by(mobile_number: params[:mobile_number])
    self.otp_request_type_id = params[:type]
  end

  def validate
    unless selected_user
      add_message :error, "User not found"
      return
    end

    unless params[:mobile_number] =~ Constants::VALID_MOBILE_NUMBER
      add_message :error, "Invalid mobile number"
      return
    end

    # ensuring the user cannot send an OTP before 60 seconds
    if selected_user.otp.present? and selected_user.otp_sent_at > OTP_RESEND_TIMER.seconds.ago
      # i.e. if the otp was sent < 60 seconds ago, don't resend it again
      seconds_remaining = ((selected_user.otp_sent_at + OTP_RESEND_TIMER.seconds) - DateTime.now).to_i
      messages[:error] << "You will have to wait for another #{seconds_remaining} seconds before requesting for another OTP"
    end
  end

  def pre_process
    # generating the random 6 digit OTP for a particular user and storing it in the message
    # if the last OTP was sent less than 15 minutes ago, send the same OTP back
    if selected_user.otp_request_type_id == otp_request_type_id && selected_user.otp_sent_at > 15.minutes.ago && selected_user.otp
      self.otp = selected_user.otp
      self.message = "#{otp} is your verification code."
      # else send the a new OTP after generating it
    else
      self.otp = MathUtil.generate_random_number(6)
      self.message = "#{otp} is your verification code."
    end
  end

  def process
    response = CustomMessage::Create.(selected_user, {mobile_number: [selected_user.mobile_number], message: message})
    if response.success?
      # have to save it without validation because update_attributes considers validations
      selected_user.assign_attributes(otp_count: (selected_user.otp_count+1))
      if otp != selected_user.otp
        selected_user.assign_attributes(otp: otp, otp_sent_at: DateTime.now, otp_request_type_id: otp_request_type_id)
      end
      selected_user.save(validate: false)
    else
      messages[:error] = response.messages[:error]
    end
  end

end

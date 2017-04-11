class Admin::Users::Lookup < Admin::Users::Base

  attr_accessor :selected_user, :registered, :verified, :otp_verified

  def self.call(params)
    self.new(nil, params).run
  end

  def pre_validate

  end

  def init
    self.selected_user = User.find_by_email(params[:email_mobile]) || User.find_by(mobile_number: params[:email_mobile])
  end

  def process
    if selected_user.nil?
      add_message :error, "User not found"
      self.registered = false
      return
    elsif selected_user.first_name.blank?
      self.registered = false
      add_message :error, "You have not signed up with Finly yet! Plese contact your manager for further details"
      return
    else
      if selected_user.active?
        self.registered = true
      else
        add_message :error, "Your account has been deactivated"
        self.registered = false
        return
      end
    end
    self.verified = selected_user.verified
    self.otp_verified = selected_user.otp_verified
  end

  def success
    params[:registered] = registered
    params[:verified] = verified
    params[:otp_verified] = otp_verified
    User::Lookup::LookupPresenter.new(user, params, messages)
  end

  class User::Lookup::LookupPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :verified, :registered, :otp_verified

    def init
      self.verified = params[:verified]
      self.registered = params[:registered]
      self.otp_verified = params[:otp_verified]
    end
  end
end
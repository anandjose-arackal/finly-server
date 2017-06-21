class Report::ReportAuthorizer::Base < BaseOperation
  attr_accessor :report, :user, :view_role_id, :email_authorization
  def initialize(params={})
    clear_messages
    self.params = (ActionController::Parameters.new(params) or {})
  end

  def init
    token = params[:token]
    # Token validation

    self.email_authorization = EmailAuthorization.with_token(token).with_valid.first
    unless email_authorization.present?
      add_message :error, 'Invalid/Expired Token'
      return
    end

    unless params[:view].present?
      add_message :error, "View is not passed."
      return
    end

    case params[:view]
      when 'manager'
        self.view_role_id = 3
      when 'finance_manager'
        self.view_role_id = 2
      when 'admin'
        self.view_role_id = 1
      when 'personal'
        self.view_role_id = 4
      else
        self.view_role_id = 4
    end 

    self.user = email_authorization.user

    self.report = email_authorization.authorizable
  end

  def self.call(params={})
    self.new(params).run
  end

  def validate
    unless report.processing?
      add_message :error, "Report is not in processing state."
    end

    unless email_authorization.view_role_id == self.view_role_id
      add_message :error, "You are not allowed in current view."
    end
  end

  def process
  end

  def success
    Report::Base::Presenter.new(self.user, {report: self.report, view: params[:view]}, messages)
  end

  # def failure
  # end

end
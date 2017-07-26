class Event::EAdmin::EVerifier::AssignAlert < Event::EAdmin::AdminSetNotifier
  attr_accessor :admin_user, :after,
                :new_assign_requests_count, :assign_requests_count, :new_card_assign_requests

  def pre_validate
    unless user.present? or params&.dig(:admin_user).present?
      add_message :error, 'User not found'
    end
  end

  def init
    self.after = params&.dig(:after)
    self.admin_user = (params&.dig(:admin_user) or user)
    return unless self.admin_user.present?
    init_assign_requests
  end

  def init_assign_requests
    assign_request_presenter = Admin::Cards::AssignRequests::Index.(self.admin_user)
    unless assign_request_presenter.success?
      add_message :error, assign_request_presenter.messages[:error]
      return
    end
    card_assign_requests = assign_request_presenter.card_assign_requests
    self.assign_requests_count = card_assign_requests.count

    request_ids = card_assign_requests.pluck(:id)
    requests = CardAssignRequestTrack.with_card_assign_request(request_ids)
    if self.after.present?
      requests = requests.created_after(self.after)
    end
    self.new_card_assign_requests = card_assign_requests.with_id(requests.pluck(:card_assign_request_id)).uniq
    self.new_assign_requests_count = self.new_card_assign_requests.count
  end

  def validate
    if self.admin_user.blank?
      add_message :error, 'User not found'
    end
    if self.new_assign_requests_count == 0
      add_message :error, 'No new requests'
    end
  end

  def mailer_affected_users
    [self.admin_user]
  end

  def mailer_subject(user)
    "#{(new_assign_requests_count)} new assign requests"
  end

  def allow_mailer(user, configuration)
    true
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:new_card_assign_requests] = self.new_card_assign_requests
    params[:new_assign_requests_count] = self.new_assign_requests_count
    params[:assign_requests_count] = self.assign_requests_count
    params[:attachment] = generate_attachment
    params[:attachment_name] = 'Card Assign Requests.xls'
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present?
    VerifierPendingAssignMailer.delay.send_mail(Event::EAdmin::EVerifier::AssignAlert::MailerPresenter.new(user, params))
  end

  class Event::EAdmin::EVerifier::AssignAlert::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :user, :subject_val, :company,
                  :new_card_assign_requests, :new_assign_requests_count, :assign_requests_count,
                  :attachment, :attachment_name

    def initialize(user, params)
      self.user = user
      self.subject_val = params[:subject]
      self.assign_requests_count = params[:assign_requests_count]
      self.new_card_assign_requests = params[:new_card_assign_requests]
      self.new_assign_requests_count = params[:new_assign_requests_count]
      self.attachment = params[:attachment]
      self.attachment_name = params[:attachment_name]
    end

    def to
      self.user.email
    end

    def subject
      self.subject_val
    end

  end

  protected
  def generate_attachment
    headers = ['Email ID', 'Mobile No', 'Disty Name', 'Address 1', 'Address 2', 'DOB', 'Gender', 'State', 'PIN code', 'First Name', 'Last Name', 'Mothers Maiden Name', 'Serial ID', 'KYC Type', 'Kyc Number']
    contents = []
    self.new_card_assign_requests.each do |card_assign_request|
      user = card_assign_request.card_owner
      profile = user.profile
      contents << [
          user.email,
          user.mobile_number,
          nil,
          profile.address_1,
          profile.address_2,
          profile.date_of_birth,
          profile.gender,
          profile.state.name,
          profile.pin_code,
          user.first_name,
          user.last_name,
          user.mothers_maiden_name,
          card_assign_request.card.proxy,
          user&.individual_kyc&.type&.name,
          user&.individual_kyc&.kyc_number
      ]
    end
    Exporter::Spreadsheet.new(self.admin_user, headers: headers, contents: contents).generate_xls
  end


end
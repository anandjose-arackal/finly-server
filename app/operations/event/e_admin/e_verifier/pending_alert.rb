class Event::EAdmin::EVerifier::PendingAlert < Event::SetNotifier
  attr_accessor :admin_user,
                :new_assign_requests_count, :assign_requests_count,
                :new_upgrade_requests_count, :upgrade_requests_count

  def pre_validate
    unless params&.dig(:admin_user).present?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.admin_user = params[:admin_user]
    return unless self.admin_user.present?
    init_assign_requests
    return unless has_errors?
    init_upgrade_requests
    return unless has_errors?
  end

  def init_assign_requests
    assign_request_presenter = Admin::Cards::AssignRequests::Index.(self.admin_user)
    unless assign_request_presenter.success?
      add_message :error, assign_request_presenter.messages[:error]
      return
    end
    card_assign_requests = assign_request_presenter.card_assign_requests
    self.assign_requests_count = card_assign_requests.count

    request_ids =  card_assign_requests.pluck(:id)
    self.new_assign_requests_count = CardAssignRequestTrack.with_card_assign_request(request_ids).created_after(DateTime.now - 1.hour).pluck(:card_assign_request_id).uniq
  end

  def init_upgrade_requests
    upgrade_requests_presenter = Admin::KycProcesses::Users::Index.(self.admin_user)
    unless upgrade_requests_presenter.success?
      add_message :error, assign_request_presenter.messages[:error]
      return
    end
    individual_kycs = upgrade_requests_presenter.individual_kycs
    self.upgrade_requests_count = individual_kycs.count

    request_ids =  individual_kycs.pluck(:id)
    self.new_upgrade_requests_count = IndividualKycTrack.with_individual_kyc(request_ids).created_after(DateTime.now - 1.hour).pluck(:individual_kyc_id).uniq
  end

  def validate
    if self.admin_user.blank?
      add_message :error, 'User not found'
    end
    if self.new_assign_requests_count == 0 and self.new_assign_requests_count == 0
      add_message :error, 'No new requests'
    end
  end

  def mailer_affected_users
    [self.admin_user]
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    VerifierPendingMailer.delay.send_mail(Event::EAdmin::EVerifier::PendingAlert::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
    "#{(new_upgrade_requests_count + new_assign_requests_count)} new upgrade requests"
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:upgrade_requests_count] = upgrade_requests_count
    params[:new_upgrade_requests_count] = new_upgrade_requests_count
    params[:assign_requests_count] = assign_requests_count
    params[:new_assign_requests_count] = new_assign_requests_count
  end

  class Event::EAdmin::EVerifier::PendingAlert::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :user, :subject_val, :company,
                  :upgrade_requests_count, :new_upgrade_requests_count,
                  :assign_requests_count, :new_assign_requests_count

    def initialize(user, params)
      self.user = user
      self.company = user.company
      self.subject_val = params[:subject]
      self.upgrade_requests_count = params[:upgrade_requests_count]
      self.new_upgrade_requests_count = params[:new_upgrade_requests_count]
      self.assign_requests_count = params[:assign_requests_count]
      self.new_assign_requests_count = params[:new_assign_requests_count]
    end

    def to
      self.user.email
    end

    def subject
      self.subject_val
    end

  end


end
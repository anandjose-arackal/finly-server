class EmailAuthorizations::Create < EmailAuthorizations::Base
  attr_accessor :authorizable, :token, :email_authorization, :authorizable_view_id, :reviewers
  def init
    self.authorizable = params[:authorizable]
    unless authorizable.instance_of?(Report) || authorizable.instance_of?(MoneyRequest) || authorizable.instance_of?(TravelRequest)
      add_message :error, "Wrong Authorizable type provided."
      return
    end

    self.authorizable_view_id = UserRole.id_for(params[:authorizable_view]) || UserRole.id_for(:manager)

    self.reviewers = authorizable.get_reviewers
    # user_id = authorizable.get_reviewers controlling_user_id
    # view_role_id = authorizable.controlling_user_role_id
    # e_auth = EmailAuthorization.with_user_id(user_id).with_authorizable(authorizable).with_view_role_id(authorizable_view_id).limit(1)
    # self.email_authorization = e_auth&.first
  end

  def validate
    unless authorizable.processing?
      add_message :error, "Cannot create authorization when authorizable is not in processing state."
      return
    end
    if self.reviewers.blank?
      add_message :error, "Please add reviewers to policy"
      return
    end
  end

  def process
    authorization_ids = []
    self.reviewers.pluck(:id).each do |user_id|
      email_authorization = EmailAuthorization.with_user_id(user_id).with_authorizable(authorizable).with_view_role_id(authorizable_view_id).limit(1).first
      unless email_authorization
        authorization_ids << create_email_authorization(user_id) if create_email_authorization(user_id).is_a?(Integer)
      else
        email_authorization.update_attributes(is_valid: true)
        authorization_ids << email_authorization.id
      end
    end
    self.email_authorization = EmailAuthorization.where(id: authorization_ids)
  end

  def create_email_authorization(user_id)
    self.token = nil
    loop do
      self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
      break unless EmailAuthorization.with_token(self.token).present?
    end

    authorization = EmailAuthorization.new(
      user_id: user_id,
      authorizable: authorizable,
      view_role_id: authorizable_view_id,
      token: token
    )
    unless authorization.save
      add_message :error, "Couldn't save."
      return
    end
    return authorization.id
  end

  def post_process
  end

  def success
    params[:email_authorization] = self.email_authorization
    EmailAuthorizations::Create::Presenter.new(user, params, messages)
  end

  class EmailAuthorizations::Create::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :email_authorization

    def init
      self.email_authorization = params[:email_authorization]
    end

  end
end
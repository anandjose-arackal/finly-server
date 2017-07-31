class Admin::Users::AgreementsMail < Admin::Base

  attr_accessor :selected_user, :email_authorization_token, :email_authorizations, :agreements

  def init
    id = params[:id] || params[:user_id]
    self.selected_user = User.find_by(id: id)

    self.agreements = []
    agreement_types = []

    # What agreement types to show
    if selected_user.company.d_code_enabled?
      agreement_types = AgreementType.all
    else
      # Show all expcept prepaid card agreement
      AgreementType.all.each do |agreement_type|
        unless agreement_type.name == 'prepaid_card_agreement'
          agreement_types << agreement_type
        end
      end
    end

    # All Active agreemeents to be shown
    agreement_types.each do |type|
      agreement = ::Agreement.all.active.with_type_id(type.id)&.first
      self.agreements << agreement
    end

  end

  def validate
    unless selected_user
      add_message :error, "User not found"
      return
    end
    unless selected_user&.default_password
      add_message :error, "This user has already changed their default passsword"
    end
  end

  def process
    self.email_authorization_token = nil
    loop do
      self.email_authorization_token = Digest::SHA1.hexdigest([Time.now, rand].join)
      break unless EmailAuthorization.with_token(self.email_authorization_token).present?
    end

    self.agreements.each do |agreement|
      email_authorization = EmailAuthorization.new(
          user_id: selected_user.id,
          authorizable: agreement,
          token: email_authorization_token
      )
      unless email_authorization.save
        add_message :error, "Couldn't save."
      end
    end
  end

  def post_process
    if selected_user.email.present?
      add_message :success, "Email invite sent"
      UserMailer.delay.agreements_mail(selected_user, self.email_authorization_token)
    else
      # todo - if the user has no email, send him/her an SMS asking them to login from www.finly.io
    end
  end
end
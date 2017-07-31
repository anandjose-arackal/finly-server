class Agreements::AgreementAuthorizer::Agree < Agreements::AgreementAuthorizer::Base
  attr_accessor :agreements, :email_authorizations, :user

  def init
    # todo get ip address
    token = params[:token]

    self.email_authorizations = EmailAuthorization.with_token(token).with_valid
    unless email_authorizations.present?
      add_message :error, 'Invalid/Expired Token'
      return
    else
      self.user = User.find(email_authorizations.first.user_id)
      self.agreements = ::Agreement.with_id(email_authorizations.pluck(:authorizable_id))
    end
  end

  def process
    self.agreements.each do |agreement|
      company_agreement_track = CompanyAgreementTrack.with_user(user.id).with_agreement(agreement.id)
      unless company_agreement_track.present?
        company_agreement_track = CompanyAgreementTrack.new(user: user, agreement_id: agreement.id, ip_address: params[:ip_address], company_id: user.company.id)
        unless company_agreement_track.save
          add_message :error, company_agreement_track.errors.full_messages
          return
        end
      end
    end

    self.email_authorizations.update_all(is_valid: false)

    add_message :success, "You agreed to all the agreements. Thank You"
  end


  def success
    Agreements::AgreementAuthorizer::Agree::Presenter.new(user, params, messages)
  end

  class Agreements::AgreementAuthorizer::Agree::Presenter < BaseOperation::BasePresenter::SuccessPresenter

  end
end
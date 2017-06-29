class Agreements::Validate < Agreements::Base

  attr_accessor :agreed, :kyc_required, :point_of_contact

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, "No user or params present."
    end
  end

  def init

  end

  def validate

  end

  def process
    self.point_of_contact = user.point_of_contact

    self.agreed = true

    active_agreements_id = Agreement.active.pluck(:id)

    if active_agreements_id.present?
      active_agreements_id.each do |agreement_id|
        user_agreement = CompanyAgreementTrack.with_user(user.id).with_agreement(agreement_id)
        unless user_agreement.present?
          self.agreed = false
        end
      end
    end

    self.kyc_required = user.company.kyc_required?
  end

  def success
    params[:agreed] = self.agreed
    params[:kyc_required] = self.kyc_required
    params[:point_of_contact] = self.point_of_contact
    Agreements::Validate::Presenter.new(user, params, messages)
  end

  class Agreements::Validate::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :agreed, :kyc_required, :point_of_contact

    def init
      self.agreed = params[:agreed]
      self.kyc_required = params[:kyc_required]
      self.point_of_contact = params[:point_of_contact]
    end
  end
end

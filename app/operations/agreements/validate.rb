class Agreements::Validate < BaseOperation
  attr_accessor :agreed, :kyc_required
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
    # self.agreements = []
    self.agreed = true

    active_agreements_id = Agreement.active.pluck(:id)

    if active_agreements_id.present?
      active_agreements_id.each do |agreement_id|
        user_agreement = UserAgreementTrack.with_user(user.id).with_agreement(agreement_id)
        unless user_agreement.present?
          self.agreed = false
        end
      end
    end

    self.kyc_required = user.company.kyc_required?
    # Agreement.with_type_id(1).active
  end

  def success
    params[:agreed] = self.agreed
    params[:kyc_required] = self.kyc_required
    Agreements::Validate::Presenter.new(user, params, messages)
  end

  class Agreements::Validate::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :agreed, :kyc_required

    def init
      self.agreed = params[:agreed]
      self.kyc_required = params[:kyc_required]
    end
  end
end
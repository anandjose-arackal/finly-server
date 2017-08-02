class Admin::KycProcesses::Users::Base < Admin::Base
  attr_accessor :individual_kycs

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
    if params&.dig(:individual_kyc_id).blank? and params&.dig(:id).blank? and params&.dig(:individual_kycs).blank?
      add_message :error, 'KYC Upgrade Request not found'
    end
  end

  def init
    self.individual_kycs = params&.dig(:individual_kycs)
    return unless self.individual_kycs.blank?
    individual_kycs_presenter = Admin::KycProcesses::Users::Index.(user, params)
    unless individual_kycs_presenter.success?
      add_message :error, individual_kycs_presenter.messages[:error]
      return
    end
    id = (params[:id] or params[:individual_kyc_id])
    if id.present?
      id = id.split(',')
    end
    self.individual_kycs = individual_kycs_presenter.individual_kycs.with_id(id)
  end

  def validate
    if self.individual_kycs.blank?
      add_message :error, 'KYC Upgrade Request not found'
    end
  end

end
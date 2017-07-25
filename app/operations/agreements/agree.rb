class Agreements::Agree < Agreements::Base
  attr_accessor :agreements, :agree, :company

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params present."
      return
    end
    unless params[:agree].present?
      add_message :error, "You cannot proceed without agreeing to the agreements"
      return
    end
  end

  def init
    if params[:agree].to_i == 1
      self.agree = true
    end
    self.company = user.company
  end

  def validate
    unless self.agree
      add_message :error, "You cannot proceed without agreeing to the agreements"
      return
    end
  end

  def process
    active_agreements_id = Agreement.active.pluck(:id)

    active_agreements_id.each do |agreement_id|
      company_agreement_track = CompanyAgreementTrack.with_user(user.id).with_agreement(agreement_id)

      unless company_agreement_track.present?
        company_agreement_track = CompanyAgreementTrack.new(user: user, agreement_id: agreement_id, ip_address: params[:ip_address], company_id: company.id)
        unless company_agreement_track.save
          add_message :error, company_agreement_track.errors.full_messages
          return
        end
      end
    end
  end

  def post_process
    # if the documents are uploaded and confirmed from the admin panel, trigger a mail to ItzCash
    # if company.company_kyc.processing?
    #   trail = company.company_kyc.company_kyc_trails.build(action_resource: user, action_id: CompanyKycTrailAction.id_for(:sent_to_itzcash)).save
    #   CompanyMailer.delay.send_to_itzcash(company)
    # end

    add_message :success, "You agreed to all the agreements."
  end

end

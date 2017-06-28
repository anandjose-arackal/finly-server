class Agreements::Agree < Agreements::Base
  attr_accessor :agreements, :agree

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
  end

  def validate
    unless self.agree
      add_message :error, "You cannot proceed without agreeing to the agreements"
    end
  end

  def process
    # self.agreements = []

    active_agreements_id = Agreement.active.pluck(:id)

    active_agreements_id.each do |agreement_id|
      
      user_login_track = UserAgreementTrack.with_user(user.id).with_agreement(agreement_id)

      unless user_login_track.present?
        user_login_track = UserAgreementTrack.new(user: user, agreement_id: agreement_id, ip_address: params[:ip_address])
        unless user_login_track.save
          add_message :error, user_login_track.errors.full_messages
          return
        end
      end
    end
    # Agreement.with_type_id(1).active
  end

  def post_process
    add_message :success, "You agreed to all the agreements."
  end

  private

  def agreement_params
    params.require(:company_kyc).permit(:pin_code, :date_of_establishment, :registered_mobile_number, :pan_card_no, :customer_type_id)
  end
end

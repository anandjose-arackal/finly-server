class Admin::KycProcesses::Companies::Reject < Admin::KycProcesses::Companies::Base

  attr_accessor :company, :rej_params, :company_kyc, :system_message_params

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    id = params[:id] || params[:company_id]
    self.company = Company.find_by(id: id)
    self.rej_params = rejection_params
    self.company_kyc = company.company_kyc
  end

  def validate
    if company.blank? || company_kyc.blank?
      add_message :error, "Company not found"
    end
  end

  def pre_process
    # set the kyc status as error for this particular company
    message = rejection_params[:message]
    doc_type = rejection_params[:document_type]
    rej_params.delete(:message)
    rej_params.delete(:document_type)
    rej_params[:kyc_status_id] = KycStatus.id_for(:error)
    rej_params.permit!
    self.system_message_params = {
        content: "Your KYC was rejected because: #{message}",
        system_message_type_id: SystemMessageType.id_for(:error),
        message_type: doc_type
    }
  end

  def process
    system_message = company_kyc.system_messages.build(system_message_params)
    if system_message.save
      company_kyc.update(rej_params)
    else
      add_message :error, system_message.errors.full_messages
    end
  end

  def post_process
    # todo - create a notification for the user to let them know that there is an error in the documents uploaded
    poc = company.users.where(point_of_contact: true).first
    # notification = poc.notification.build()

    # set the kyc status as error for this particular company
    company_kyc.update(kyc_status_id: KycStatus.id_for(:error))
    add_message :success, "User successfully notified"
  end

  private

  def rejection_params
    params.require(:company_kyc).permit(:message, :document_type)
  end
end
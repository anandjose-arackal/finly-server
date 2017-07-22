class KycProcess::Company::Update < KycProcess::Company::Base
  attr_accessor :kyc_params, :uploaded_docs

  def pre_validate
    super()
    if params[:company_kyc].blank?
      add_message :error, "No params passed, try again"
    end
  end

  def init
    super
    self.kyc_params = kyc_strong_params
  end

  def validate
    # depending on the type of company, we will be checking the documents that are uploded
  end

  def pre_process
    # here we'll be storing the documents that are being uploaded again, for later destroying the system messages associated with them
    self.uploaded_docs = []
    kyc_params[:kyc_documents_attributes].each do |doc|
      self.uploaded_docs << doc[:identifier]
    end
  end

  def process
    unless self.company_kyc.update(self.kyc_params)
      add_message :error, self.company_kyc.errors.full_messages
    end
  end

  def post_process
    # clearing all system messages that were associated with the uploaded KYC documents
    uploaded_docs.each do |doc|
      company_kyc.system_messages.send("#{doc}_messages").destroy_all
    end

    # update the status based on the company type and documents uploaded
    case company_kyc.company_type_id
      when CompanyType.id_for('Sole Proprietor')
        if company_kyc.kyc_documents.pan_card.present? && company_kyc.kyc_documents.id_proof.present? && company_kyc.kyc_documents.address_proof.present? && company_kyc.system_messages.empty?
          company_kyc.update(kyc_status_id: KycStatus.id_for(:submitted))
        else
          company_kyc.update(kyc_status_id: KycStatus.id_for(:incomplete))
        end
      when CompanyType.id_for('Partnership Firm')
        if company_kyc.kyc_documents.pan_card.present? && (company_kyc.kyc_documents.partnership_deed.present? || company_kyc.kyc_documents.certificate_of_registration.present?) && company_kyc.kyc_documents.list_of_partners.present? && company_kyc.kyc_documents.supporting_document.present? && company_kyc.system_messages.empty?
          company_kyc.update(kyc_status_id: KycStatus.id_for(:submitted))
        else
          company_kyc.update(kyc_status_id: KycStatus.id_for(:incomplete))
        end
      when CompanyType.id_for('Private Ltd Company')
        if company_kyc.kyc_documents.pan_card.present? && company_kyc.kyc_documents.certificate_of_incorporation.present? && company_kyc.system_messages.empty?
          company_kyc.update(kyc_status_id: KycStatus.id_for(:submitted))
        else
          company_kyc.update(kyc_status_id: KycStatus.id_for(:incomplete))
        end
      when CompanyType.id_for('Ltd Liability Partnership')
        if company_kyc.kyc_documents.pan_card.present? && company_kyc.kyc_documents.certificate_of_incorporation.present? && company_kyc.kyc_documents.list_of_partners_din.present? && company_kyc.kyc_documents.supporting_document.present? && company_kyc.system_messages.empty?
          company_kyc.update(kyc_status_id: KycStatus.id_for(:submitted))
        else
          company_kyc.update(kyc_status_id: KycStatus.id_for(:incomplete))
        end
      when CompanyType.id_for('Trust and Societies')
        if company_kyc.kyc_documents.pan_card.present? && (company_kyc.kyc_documents.certificate_of_registration.present? || company_kyc.kyc_documents.trust_deed.present?) && company_kyc.kyc_documents.list_of_trustees_karta.present? && company_kyc.kyc_documents.supporting_document.present? && company_kyc.system_messages.empty?
          company_kyc.update(kyc_status_id: KycStatus.id_for(:submitted))
        else
          company_kyc.update(kyc_status_id: KycStatus.id_for(:incomplete))
        end
    end

    add_message :success, "Documents uploaded successfully"

  end

  def success
    params[:processing] = company.company_kyc.processing?
    KycProcess::Company::Update::KycPresenter.new(user, params, messages)
  end

  class KycProcess::Company::Update::KycPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :completed

    def init
      # because completed from the user's perspective the process (uploading) is completed
      self.completed = params[:processing]
    end
  end

  protected

  def kyc_strong_params
    p = {}
    p[:kyc_documents_attributes] = []
    params[:company_kyc].each do |key, value|
      p[:kyc_documents_attributes] << {
          doc: value,
          identifier: key,
          company_kyc_document_type_id: CompanyKycDocumentType.id_for(CompanyKycDocumentType.name_for(key))
      }
      if company_kyc.kyc_documents.send("#{key}").present?
        p[:kyc_documents_attributes][0][:id] = company_kyc.kyc_documents.send("#{key}").first.id
      end
    end
    p
  end

end
class CompanyMailer < ApplicationMailer

  def balance_update(transaction_details)
    @amount = transaction_details[:amount_attributes][:value] rescue nil
    @reference_id = transaction_details[:reference_id]
    @date = transaction_details[:date]
    @remarks = transaction_details[:remark]
    @company = transaction_details[:company]
    mail to: Constants::ITZCASH_EMAIL_ID, subject: "Transaction Details for Company: #{transaction_details[:company]}"
  end

  # mailer that is sent to ItzCash when all documents have been confirmed as sent from the user
  def send_to_itzcash(company)
    @company = company
    @company_kyc = company.company_kyc
    @documents = @company_kyc.kyc_documents
    @pre_paid_card_agreement = Agreement.active.with_type_id(AgreementType.id_for(:prepaid_card_agreement)).first
    @agreement_track = CompanyAgreementTrack.with_company(@company.id).with_agreement(@pre_paid_card_agreement&.id).first
    @documents.each do |doc|
      attachments["#{doc.company_kyc_document_type.name}.#{doc.doc_file_name.split('.').last}"] = File.read(doc.doc.path)
    end
    # can add more details here as we need
    mail to: Constants::ITZ_CASH_KYC_EMAIL, from: "sales@finly.io", cc: Constants::ITZ_CASH_KYC_CARBON_COPY_EMAIL, subject: "KYC Documents for #{company.name}"
  end

end

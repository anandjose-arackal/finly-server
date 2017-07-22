class KycProcess::Company::Show < KycProcess::Company::Base

  def process

  end

  def success
    params[:company_kyc] =  self.company_kyc
    KycProcess::Company::Show::DocumentsPresenter.new(user, params, messages)
  end

  class KycProcess::Company::Show::DocumentsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :company_kyc, :completed, :actions

    def init
      self.company_kyc = params[:company_kyc]
      self.completed = company_kyc.completed?
      self.actions = retrieve_actions
    end

    def retrieve_actions
      actions = {}
      if company_kyc.kyc_status_id == KycStatus.id_for(:incomplete) || company_kyc.kyc_status_id == KycStatus.id_for(:rejected)
        actions[:upload] = Rails.application.routes.url_helpers.kyc_docs_update_path
      elsif company_kyc.kyc_status_id == KycStatus.id_for(:submitted)
        actions[:upload] = Rails.application.routes.url_helpers.kyc_docs_update_path
        actions[:confirm] = Rails.application.routes.url_helpers.kyc_confirm_path
        # because the admin panel operation inherits this one, and this needs to be shown only if the particular user is a Finly Admin
        if user.finly_admin? || user.is_a?(AdminUser)
          actions[:reject] = Rails.application.routes.url_helpers.admin_users_kyc_company_reject_path(company_kyc.company)
          actions[:confirm] = Rails.application.routes.url_helpers.admin_users_kyc_company_confirm_path(company_kyc.company)
        end
      elsif company_kyc.kyc_status_id == KycStatus.id_for(:submitted)
        if user.finly_admin?
          # do nothing, HA!
        else
          actions[:retract] = Rails.application.routes.url_helpers.kyc_reject_path
        end
      end
      actions
    end

    def editable?
      if user.finly_admin?
        true
      else
        if company_kyc.editable?
          true
        else
          false
        end
      end
    end

    def documents
      company_kyc.required_document_files
    end

  end

end
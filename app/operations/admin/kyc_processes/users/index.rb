class Admin::KycProcesses::Users::Index < Admin::KycProcesses::Users::Base
  attr_accessor :individual_kycs, :workflow, :reviewer_level

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.workflow = AdminReviewWorkflow.workflow_for :kyc_update
    self.reviewer_level = workflow.levels.with_admin_reviewer(user.id)&.first
    if self.workflow.present? and self.reviewer_level.present?
      self.individual_kycs = IndividualKyc.with_admin_review_workflow(self.workflow.id).with_review_position(reviewer_level.position)
    else
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def validate

  end

  def success
    params[:individual_kycs] = self.individual_kycs
    Admin::KycProcesses::Users::Index::SuccessPresenter.new(user, params, messages)
  end

  class Admin::KycProcesses::Users::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :individual_kycs

    has_scope :filter_company

    def init
      self.individual_kycs = params[:individual_kycs]
      self.individual_kycs = apply_scopes(self.individual_kycs).paginate(page: params[:page], per_page: 30) if self.individual_kycs.present?
    end

    def company_for(individual_kyc)
      individual_kyc&.user&.company
    end

    def actions_for(individual_kyc)
      actions = {}
      return actions if individual_kyc.blank? or not individual_kyc.processing?
      if user.has_role?(AdminUserRole.id_for(:verifier)) or user.has_role?(AdminUserRole.id_for(:itzcash_verifier))or
          user.has_role?(AdminUserRole.id_for(:itzcash_operations))
        is_reviewer_presenter = Admin::KycProcesses::Users::IsReviewer.(user, admin_user: user, individual_kyc: individual_kyc)
        if is_reviewer_presenter.success? and is_reviewer_presenter.is_reviewer
          actions[:approve] = true
          actions[:reject] = true
        end
      end
      next_reviewer_presenter = Admin::KycProcesses::Users::NextAdminReviewPosition.(user, admin_user: user, individual_kyc: individual_kyc)
      if next_reviewer_presenter.success? and next_reviewer_presenter.is_final? and user.has_role?(AdminUserRole.id_for(:itzcash_operations))
        actions.delete(:approve)
        actions[:mark_as_upgraded] = true
      end
      actions
    end
  end

end
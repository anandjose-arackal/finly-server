class Settlement::SReport::Processing::Index < Settlement::SReport::Processing::Base
  attr_accessor :report_processor_groups

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.report_processor_groups = current_company.report_processor_groups.not_completed
    if finance_view?
      self.report_processor_groups = self.report_processor_groups.created_by_user(user.id)
    end
  end

  def success
    params[:report_processor_groups] = self.report_processor_groups
    Settlement::SReport::Processing::Index::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SReport::Processing::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :report_processor_groups, :paginated_report_processor_groups

    has_scope :filter_search
    has_scope :filter_user_id
    has_scope :filter_created_by_user_id
    has_scope :filter_payment_type
    has_scope :filter_date
    has_scope :filter_scheduled_date
    has_scope :filter_completed_date

    def init
      self.report_processor_groups = params[:report_processor_groups]
      per_page = params[:per_page] || 30
      self.report_processor_groups = apply_scopes(self.report_processor_groups, params)
      self.paginated_report_processor_groups = self.report_processor_groups&.include_for_index.paginate(page: params[:page], per_page: per_page)
    end

    def actions_for(processor_group)
      actions = {}
      if processor_group.pending? or processor_group.scheduled? or processor_group.failed?
        actions[:cancel] = true
      end

      if processor_group.partially_completed?
        actions[:cancel_pending] = true
      end

      if processor_group.process_outside_finly?
        actions[:mark_as_paid] = true
      end

      if processor_group.payment_file?
        actions[:generate_payment_file] = true
      end

      actions
    end

  end

end
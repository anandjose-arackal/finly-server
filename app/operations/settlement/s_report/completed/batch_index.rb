class Settlement::SReport::Completed::BatchIndex < Settlement::SReport::Completed::Base
  attr_accessor :report_processor_groups

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.report_processor_groups = current_company.report_processor_groups.completed
    if finance_view?
      self.report_processor_groups = self.report_processor_groups.created_by_user(user.id)
    end
  end

  def success
    params[:report_processor_groups] = self.report_processor_groups
    Settlement::SReport::Completed::BatchIndex::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SReport::Completed::BatchIndex::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :report_processor_groups, :paginated_report_processor_groups

    has_scope :filter_search
    has_scope :filter_user_id
    has_scope :filter_created_by_user_id
    has_scope :filter_payment_type
    has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_scheduled_date, using: [:from, :to], type: :hash
    has_scope :filter_completed_date, using: [:from, :to], type: :hash

    def init
      self.report_processor_groups = params[:report_processor_groups]
      per_page = params[:per_page] || 30
      self.report_processor_groups = apply_scopes(self.report_processor_groups, params)
      self.paginated_report_processor_groups = self.report_processor_groups&.include_for_show.paginate(page: params[:page], per_page: per_page)
    end

  end


end
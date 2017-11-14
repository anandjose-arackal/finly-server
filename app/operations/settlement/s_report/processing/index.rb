class Settlement::SReport::Processing::Index < Settlement::SReport::Processing::Base
  attr_accessor :report_processor_groups

  class Settlement::SReport::Processing::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :report_processor_groups, :paginated_report_processor_groups

    def init
      self.report_processor_groups = params[:report_processor_groups]
      per_page = params[:per_page] || 30
      self.paginated_report_processor_groups = self.report_processor_groups&.include_for_show.paginate(page: params[:page], per_page: per_page)
    end

  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.report_processor_groups = current_company.report_processor_groups
    if finance_view?
      self.report_processor_groups = self.report_processor_groups.created_by_user(user.id)
    end
  end

  def success
    params[:report_processor_groups] = self.report_processor_groups
    Settlement::SReport::Processing::Index::SuccessPresenter.new(user, params, messages)
  end

end
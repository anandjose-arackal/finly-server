class Settlement::SMoneyRequest::Processing::Index < Settlement::SMoneyRequest::Processing::Base
  attr_accessor :report_processor_groups

  class Settlement::SMoneyRequest::Processing::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :report_processor_groups

    def init
      self.report_processor_groups = params[:report_processor_groups]
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
    Settlement::SMoneyRequest::Processing::Index::SuccessPresenter.new(user, params, messages)
  end

end
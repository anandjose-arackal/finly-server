class Settlement::SReport::Processing::Show < Settlement::SReport::Processing::Base
  attr_accessor :report_processor_group

  def pre_validate
    if params[:id].blank?
      add_message :error, "Details for processing reports not sent."
      return
    end
  end

  def init
    request_id = params[:id] || params[:report_id] || params[:report_processor_group_id]

    self.report_processor_group = current_company.report_processor_groups.not_completed&.find_by(id: request_id)
    if finance_view?
      self.report_processor_group = self.report_processor_groups.created_by_user(user.id)&.find_by(id: request_id)
    end
  end

  def validate
    if self.report_processor_group.blank?
      add_message :error, "Details for processing reports not found."
      return
    end
  end

  def pre_process

  end

  def process

  end

  def success
    params[:report_processor_group] = self.report_processor_group
    Settlement::SReport::Processing::Show::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SReport::Processing::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :report_processor_group, :paginated_mappings, :mappings

    def init
      self.report_processor_group = params[:report_processor_group]

      self.mappings = self.report_processor_group.mappings
      per_page = params[:per_page] || 30
      self.paginated_mappings = self.mappings.paginate(page: params[:page], per_page: per_page)
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


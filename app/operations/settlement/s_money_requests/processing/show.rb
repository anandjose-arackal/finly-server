class Settlement::SMoneyRequests::Processing::Show < Settlement::SMoneyRequests::Processing::Base
  attr_accessor :money_request_processor

  def pre_validate
    if params[:id].blank?
      add_message :error, "Details for advance processing not sent."
      return
    end
  end

  def init
    request_id = params[:id] || params[:money_request_id] || params[:money_request_processor_id]
    self.money_request_processor = current_company.money_request_processors.not_completed&.find_by(id: request_id)
    if finance_view?
      self.money_request_processor = self.money_request_processors.created_by_user(user.id)&.find_by(id: request_id)
    end
  end

  def validate
    if self.money_request_processor.blank?
      add_message :error, "Details for advance processing not found."
      return
    end
  end

  def pre_process

  end

  def process

  end

  def success
    params[:money_request_processor] = self.money_request_processor
    Settlement::SMoneyRequests::Processing::Show::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SMoneyRequests::Processing::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :money_request_processor, :paginated_mappings, :mappings

    def init
      self.money_request_processor = params[:money_request_processor]

      self.mappings = self.money_request_processor.mappings
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
        actions[:import] = true
      end

      if processor_group.payment_file?
        actions[:generate_payment_file] = true
        actions[:import] = true
      end

      actions
    end

    def item_actions(item)
      actions = {}
      if item.processor.process_outside_finly?
        unless item.completed? or item.cancelled?
          actions[:mark_as_completed] = true
          actions[:edit_utr] = true
        end

        if item.completed?
          actions[:edit_utr] = true
        end
      end
      actions
    end

  end

end


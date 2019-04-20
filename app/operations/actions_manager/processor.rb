class ActionsManager::Processor < BaseOperation

  attr_accessor :master, :type, :actions_configuration, :result

  class ActionsManager::Processor::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :actions_configuration

    def init
      self.actions_configuration = params[:actions_configuration]
    end
  end

  def pre_validate
    unless user_present? && params_present?
      return
    end
    unless params[:type].present?
      add_message :error, 'Invalid type, some error occurred'
      return
    end

    unless params[:action].present?
      add_message :error, 'Invalid action, some error occurred'
      return
    end
  end

  def init
    self.type = params[:type]
    self.master = init_master
  end

  def validate
    if self.master.blank?
      add_message :error, "Invalid Operation"
      return
    end
    self.result = self.master.new(user, params) rescue nil

    if self.result.present?
      unless self.result.valid?
        add_message :error, result.messages[:error]
        return
      end
      if self.result.has_errors?
        add_message :error, result.messages[:error]
        return 
      end
    else
      add_message :error, "Invalid Operation"
    end

    # Validate for error
    # obj = self.master.new(user, params) rescue nil
    # if obj.messages.present? && !obj.messages[:error].blank?
    #   add_message :error, obj.messages[:error]
    #   return
    # end
  end

  def process
    # result = self.master.new(user, params).run

    # unless result.present?
    #   add_message :error, 'Some error occurred, please try again later'
    #   return
    # end
    self.actions_configuration = self.result.run
  end

  def success
    params[:actions_configuration] = actions_configuration
    ActionsManager::Processor::SuccessPresenter.new(current_user, params, messages)
  end

  protected

  def init_master
    master = ActionsManager::Master::Base::MASTERS[self.params[:type]]
    if master.present?
      return master.constantize unless master.is_a?(Class)
      return master
    end
    nil
  end

end
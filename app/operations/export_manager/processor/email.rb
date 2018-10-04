class ExportManager::Processor::Email < ExportManager::Processor::Base

  def valid?
    if self.generator.blank? or self.master.blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def run
    params[:master] = master
    params[:generator] = generator
    ExportManager::Processor::Email::BackgroundProcessor.new(user.id, params)
    add_message :success, 'The export will be sent via email within 5 minutes'
    ExportManager::Presenter::SuccessPresenter.new(user, params, messages)
  end

  class ExportManager::Processor::Email::BackgroundProcessor < BackgroundOperation
    attr_accessor :master, :generator

    def init
      self.master = params[:master]
      self.generator = params[:generator]
    end

  end

end
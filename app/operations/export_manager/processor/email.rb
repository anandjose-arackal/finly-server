class ExportManager::Processor::Email < ExportManager::Processor::Base

  def valid?
    if self.generator.blank? or self.master.blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def run
    params[:master] = master
    params[:generator_class] = generator.class.name
    params[:generator_options] = generator.options
    ExportManager::Processor::Email::BackgroundProcessor.new(user.id, params)
    add_message :success, 'The export will be sent via email within 5 minutes'
    ExportManager::Presenter::SuccessPresenter.new(user, params, messages)
  end

  class ExportManager::Processor::Email::BackgroundProcessor < BackgroundOperation
    attr_accessor :master, :generator

    def init
      self.master = params[:master]
      generator_class = Object.const_get(params[:generator_class])
      self.generator = generator_class.new(user, params, master, params[:generator_options])
    end

    def process
      self.file_url = generator.run
    end

  end

end
module ExportManager::DSL::EventProcessor
  extend ActiveSupport::Concern

  included do
    class_attr :pre_processors, default: []
    class_attr :post_processors, default: []
  end

  class_methods do
    def pre_process(process)
      pre_processors << process
    end

    def post_process(process)
      post_processors << process
    end
  end

  def pre_process!
    self.class.pre_processors.each do |process|
      if process.is_a?(Symbol)
        self.send(process)
      else
        process.call(user, params)
      end
    end
  end

  def post_process!
    self.class.post_processors.each do |process|
      if process.is_a?(Symbol)
        self.send(process)
      else
        instance_eval &process
      end
    end
  end
end
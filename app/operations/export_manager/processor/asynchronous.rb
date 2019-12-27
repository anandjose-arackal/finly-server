class ExportManager::Processor::Asynchronous < ExportManager::Processor::Base

  class Job < BackgroundOperation

    def process
      master_class = Object.const_get(params[:master_class])
      master = master_class.new(user, JSON.parse(params[:request_params]))
      generator = master_class.generator.build(master)
      generator.run
    end

  end

  def run
    Job.call_async(user, {request_params: params.to_json, master_class: master_class})
  end

end
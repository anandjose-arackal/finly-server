class ExportManager::Generator::Base < BaseOperation
  include DynamicAttributes

  attr_accessor :master, :options, :export_job, :input #, :config

  class_attr :type

  def self.setup(master_class)
    # To be inherited
  end

  def self.config(master_class)
    # To be inherited
  end

  def perform
    # To be inherited
  end

  def self.build(master)
    if master.class.generator.respond_to?(:each)
      generator = master.class.generator.first
      options = master.class.generator.second
    else
      generator = master.class.generator
      options = nil
    end
    generator.new(master, options)
  end

  def initialize(master, options)
    super(master.user, master.params)
    self.master = master
    self.options = options
  end

  def run
    self.input = master.input
    self.export_job = create_job
    perform
    notify
  end

  def build_job_name
    case master.class.job_name.class
    when Proc
      return master.job_name.call(master.user, master.params, self.input)
    when Symbol
      return master.send(master.class.job_name, master.user, master.params, self.input)
    else
      return master.job_name
    end
  end

  def create_job
    total_count = self.input.count

    # Build generator
    self.export_job = user.export_jobs.create(
        {
            name: build_job_name,
            export_type: nil,
            total_records: total_count,
            completed_records: 0,
            company_id: user.company_id,
            request_params: params,
            status_id: ExportJobStatus.id_for(:pending)
        }
    )
  end

  def progress_update(completed)
    export_job.update(completed_records: completed, completion_percentage: (completed*100/export_job.total_records))
  end

  def save_attachment(file)
    export_job.update(attachment: file)
  end

  def success!
    export_job.update(status_id: ExportJobStatus.id_for(:completed), completed_at: DateTime.now)
    ExportJobMailer.delay.success(export_job)
  end

  def failure!
    export_job.update(status_id: ExportJobStatus.id_for(:failed), completed_at: DateTime.now)
    ExportJobMailer.delay.failure(export_job)
  end

  def notify
    # Todo
  end

end
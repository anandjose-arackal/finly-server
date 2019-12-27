class ExportManager::Generator::Base < BaseOperation
  cattr_accessor :formats
  attr_accessor :master, :options, :export_job, :input #, :config

  def self.accept?(format, options = {})
    return false if self.formats.blank?
    self.formats.include?(format.to_sym)
  end

  def self.setup(master_class)

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

  def create_job
    total_count = self.input.count
    # Build generator
    self.export_job = user.export_jobs.create(
        {
            name: master.name,
            export_type: nil,
            total_records: total_count,
            completed_records: 0,
            company_id: user.company_id,
            request_params: params,
            status_id: ExportJobStatus.id_for(:pending)
        }
    )
  end

  def perform
    # To be inherited
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
module Events::Schedule::Job

  def self.add(klass)
    jobs << klass unless jobs.include? klass
  end

  def self.jobs
    @scheduled_jobs ||= []
  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def scheduled?
      !!@scheduled
    end

    def scheduled!(every:, hour:, minute:, day_of_the_week: nil, day_of_the_month: nil)
      include Sidekiq::Worker

      @scheduled = true
      @schedule = {
          every: every,
          hour: hour,
          minute: minute,
          day_of_the_week: day_of_the_week,
          day_of_the_month: day_of_the_month,
      }

      validate_schedule

      Events::Schedule::Job.add self
      setup_job

      unless self.new.respond_to?(:perform)
        define_method :perform do |type, user_id: nil, message: nil|
          on_schedule
        end
      end
    end

    def schedule
      @schedule
    end

    def validate_schedule
      # Todo raise exception if the schedule is invalid
    end

    def setup_job
      frequency = schedule[:every]
      at = "#{schedule[:day_of_the_week]} " if schedule[:day_of_the_week]
      at += "#{schedule[:hour].to_s.rjust(2, '0')}:#{schedule[:minute].to_s.rjust(2, '0')}"
      # Todo handle day of the month
      Clockwork.every frequency, self.name, at: at do
        self.perform_async(:scheduled)
      end
    end
  end

  def on_schedule

  end

end
class ProcessReports < BaseOperation
  attr_accessor :time_slot, :configurations

  def self.call
    self.new.run
  end

  def initialize
    super(nil, nil)
  end

  def init
    self.configurations = fetch_configurations
  end

  def validate
    if self.configurations.blank?
      add_message :error, 'No user has requested for summary at this time'
      return
    end
  end

  def process
    self.configurations&.each { |config| process_configuration config }
  end

  protected
  def fetch_time_slot(datetime)
    time_slot = datetime.strftime('%H')
    if datetime.minute < 30
      time_slot += ':00'
    else
      time_slot += ':30'
    end
    time_slot
  end

  def fetch_configurations
    datetime = DateTime.today
    day_of_month = datetime.day
    day_of_week = datetime.strftime("%A")
    time_slot = fetch_time_slot datetime
    SummaryMailConfiguration.configurations_for day_of_month, day_of_week, time_slot
  end

  def process_configuration(configuration)

  end

end
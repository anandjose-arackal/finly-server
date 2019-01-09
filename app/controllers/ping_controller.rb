class PingController < ApplicationController

  def ping
    render json: {success: true}
  end

  # def sidekiq
  #   sidekiq = HealthMonitor::Providers::Sidekiq.new
  #   sidekiq.check!
  #
  #   processes = ::Sidekiq::ProcessSet.new
  #   # processes.size = total number of alive processes
  #   # processes.as_json.size = total processes
  #   if processes.size != processes.as_json.size
  #     raise 'Sidekiq is down!'
  #   end
  #
  #   render json: {success: true}
  # end

  def sidekiq
    # sidekiq = HealthMonitor::Providers::Sidekiq.new
    # sidekiq.check!

    hostname = nil
    case params[:type]
    when 'general'
      hostname = 'ip-172-33-215-128.ap-south-1.compute.internal'
    when 'payments'
      hostname = 'ip-172-32-19-108.ap-south-1.compute.internal'
    else
      # Nothing
      raise 'Sidekiq machine not found'
    end

    if hostname.present?
      processes = ::Sidekiq::ProcessSet.new
      sidekiq_process = processes.as_json.select {|map| map['attribs']['hostname'] == hostname }
      # processes.size = total number of alive processes
      # processes.as_json.size = total processes
      unless sidekiq_process.present?
        raise "Sidekiq #{params[:type]} is down!"
      end
    end

    render json: {success: true}
  end

  def database
    database = HealthMonitor::Providers::Database.new
    database.check!
    render json: {success: true}
  end

end

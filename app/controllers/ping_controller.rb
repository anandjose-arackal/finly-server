class PingController < ApplicationController

  def ping
    render json: {success: true}
  end

  def sidekiq
    sidekiq = HealthMonitor::Providers::Sidekiq.new
    sidekiq.check!

    processes = ::Sidekiq::ProcessSet.new
    # processes.size = total number of alive processes
    # processes.as_json.size = total processes
    if processes.size == processes.as_json.size
      raise 'Sidekiq is down!'
    end

    render json: {success: true}
  end

  def database
    database = HealthMonitor::Providers::Database.new
    database.check!
    render json: {success: true}
  end

end

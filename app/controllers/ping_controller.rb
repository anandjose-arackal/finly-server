class PingController < ApplicationController

  def ping
    render json: {success: true}
  end

  def sidekiq
    sidekiq = HealthMonitor::Providers::Sidekiq.new
    sidekiq.check!
    render json: {success: true}
  end

  def database
    database = HealthMonitor::Providers::Database.new
    database.check!
    render json: {success: true}
  end

end

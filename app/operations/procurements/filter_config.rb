class Procurements::FilterConfig < Procurements::Base
  attr_accessor :config, :status_tags

  def init
    self.status_tags = StatusTag.all
  end

  def process
    self.config = {}
    status_tags.each do |tag|
      self.config[tag.name] = tag.id
    end
  end

  def success
    params[:config] = self.config
    Procurements::FilterConfig::ConfigPresenter.new(user, params, messages)
  end

  class Procurements::FilterConfig::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :config

    def init
      self.config = params[:config]
    end
  end
end
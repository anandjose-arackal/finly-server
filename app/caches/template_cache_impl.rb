class TemplateCacheImpl < BaseApplicationCache
  attr_accessor :your_fav_param

  def initialize(company, current_user, your_fav_param)
    @company = company
    @current_user = current_user

    @your_fav_param = your_fav_param

    cache_init
  end

  def self.enabled?
    true
  end

  def self.eager_load?
    true
  end

  def cache_instance_id
    # Override this to provide a cache identifier
  end

  def load_data
    # Fetch data from main datasource
    # Returns query set / data objects

  end

end

class FormKlassCache < BaseApplicationCache
  attr_accessor :klass_name

  def initialize(company, current_user, klass_name)
    @company = company
    @current_user = current_user

    @klass_name = klass_name

    cache_init
  end

  def self.enabled?
    SaviourCachesToggle.new(@current_user).enabled?
  end

  def self.eager_load?
    true
  end

  def cache_instance_id
    return "#{@klass_name}"
  end

  def load_data
    Form.where.not(klass_name: nil).where(klass_name: @klass_name, company_id: @company.id).preload_for_contract.first
  end
end

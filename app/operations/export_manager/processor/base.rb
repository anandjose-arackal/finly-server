class ExportManager::Processor::Base
  attr_accessor :master_class, :master, :user, :params, :generator, :file_url

  def initialize(user, params, master_class)
    self.user = user
    self.params = params
    self.master_class = master_class
    self.master = master_class.new(user, params)
    self.generator = init_generator
  end

  def run
    # To be implemented by inheriting processors
  end

  def init_generator
    generators = self.master_class.generators
    if generators.respond_to?(:each)
      self.master_class.generators.each do |gen_config|
        generator = generator_for gen_config
        return generator if generator.present?
      end
    else
      return generator_for generators
    end
    nil
  end

  def generator_for(gen_config)
    generator = gen_config
    options = nil
    if gen_config.respond_to?(:each)
      generator = gen_config.first
      options = gen_config.second
    end
    if generator.accept?(params[:export_format], options)
      return generator.new(user, params, master, options)
    end
    nil
  end

end
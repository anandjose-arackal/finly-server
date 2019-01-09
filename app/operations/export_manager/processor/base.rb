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
    self.master_class.generators.each do |gen_config|
      generator = gen_config[:generator]
      if generator.accept?(params[:export_format], gen_config[:options])
        return generator.new(user, params, master, gen_config[:options])
      end
    end
    nil
  end

end
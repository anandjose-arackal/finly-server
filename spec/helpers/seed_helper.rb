class SeedHelper

  def self.seed_test_data
    seedable_classes = ObjectSpace.each_object(Class).select { |c| c.included_modules.include?(Seedable) }
    if seedable_classes.blank?
      Dir.glob("#{Rails.root}/app/models/**/*.rb") {|f| require f}
      seedable_classes = ObjectSpace.each_object(Class).select { |c| c.included_modules.include?(Seedable) }
    end
    seedable_classes.each do |klass|
      klass.seed_data #rescue nil
    end
  end

end
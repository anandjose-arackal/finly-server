class SeedHelper

  # require "#{Rails.root}/spec/helpers/seed_helper.rb"
  # SeedHelper.seed_test_data

  def self.seed_test_data
    ActiveRecord::Migration.change_column_null :admin_review_workflow_levels, :admin_user_id, true
    # To prevent Doorkeeper::Application factory from crashing
    ActiveRecord::Migration.add_column :oauth_applications, :confidential, :boolean, default: true, null: false unless Doorkeeper::Application.has_attribute? :confidential

    seedable_classes = ObjectSpace.each_object(Class).select { |c| c.included_modules.include?(Seedable) }
    if seedable_classes.blank? or seedable_classes.size < 15
      Dir.glob("#{Rails.root}/app/models/**/*.rb") {|f| (load f rescue nil)}
      seedable_classes = ObjectSpace.each_object(Class).select { |c| c.included_modules.include?(Seedable) }
    end
    seedable_classes.each do |klass|
      klass.seed_data #rescue nil
    end
  end

end
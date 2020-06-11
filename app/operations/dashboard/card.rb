class Dashboard::Card < Trailblazer::API
  include DynamicAttributes

  class_attr :resolver
  class_attr :path
  class_attr :created_by, default: :user_id

  def self.row(options, &block)

  end

end
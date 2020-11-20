require 'action_view'
require 'action_view/helpers'

class Drawer::API
  include ActionView::Helpers::DateHelper
  include DynamicAttributes
  include Block::Builder

  class_attr :model
  class_attr :policy
  class_attr :policy_action
  class_attr :update_path


  def self.call(options)
    params = options[:params]
  end

  def initialize(user)
    @user = user
  end

  def self.build(user, record)
    record_exposure = record.to_exposure
    map = []
    self.blocks.each do |block_key, block|
      #next if required_columns.present? and not (required_columns.include?(column_key.to_s) or required_columns.include?(column_key.to_sym))
      #next if required_columns.blank? and not column.default
      data_provider = data_provider(user, record, record_exposure)

      map << block.build(data_provider, user, record, record_exposure)

    end
    {blocks: map,update_path:self.update_path}
  end

  # Data provider is used for reusing classes for fetching data
  def self.data_provider(user, record, record_exposure)
    self
  end

end
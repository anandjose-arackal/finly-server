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
  class_attr :find_by_key


  def self.call(options)
    params = options[:params]
  end

  def initialize(user)
    @user = user
  end

  def self.build(user, record)
    record_exposure = record.first.to_exposure
    map = []
    self.blocks.each do |block_key, block|
      data_provider = data_provider(user, record, record_exposure)
      map << block.build(data_provider, user, record, record_exposure)
    end
    { blocks: map,
      update_path: self.update_path }
  end

  # Data provider is used for reusing classes for fetching data
  def self.data_provider(user, record, record_exposure)
    self
  end

end
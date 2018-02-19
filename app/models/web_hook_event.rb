class WebHookEvent < ActiveRecord::Base
  include Seedable

  def self.values
    %w(collect.transaction)
  end

end

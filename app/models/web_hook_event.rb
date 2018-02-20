# == Schema Information
#
# Table name: web_hook_events
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WebHookEvent < ActiveRecord::Base
  include Seedable

  def self.values
    %w(collect.transaction)
  end

end

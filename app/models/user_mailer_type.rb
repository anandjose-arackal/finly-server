class UserMailerType < ActiveRecord::Base
  include Seedable

  def self.values
    [:daily_summary, :report, :]
  end

end

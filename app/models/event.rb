# == Schema Information
#
# Table name: events
#
#  id                :integer          not null, primary key
#  name              :string(255)      not null
#  push_notification :boolean
#  mailer            :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Event < ActiveRecord::Base

  def report_submit_id
    1
  end

end

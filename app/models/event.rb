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

  def report_approve_id
    2
  end

  def report_retract_id
    3
  end

  def report_reject_id
    4
  end

  def report_comment_id
    5
  end

  def settlement_add_advance_id
    6
  end

  def settlement_clear_debt_id
    7
  end

  def settlement_reimburse_id
    8
  end

  def settlement_settle_id
    9
  end

end

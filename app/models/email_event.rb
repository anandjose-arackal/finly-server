# == Schema Information
#
# Table name: email_events
#
#  id          :bigint           not null, primary key
#  email_id    :bigint           not null
#  event       :string(255)      not null
#  link        :string(255)
#  received_at :datetime
#  event_id    :string(255)
#  payload     :text(4294967295)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deleted_at  :datetime
#

class EmailEvent < ApplicationRecord
  belongs_to :email

  # Events
  # Send, Reject, Delivery, Open, Click, Bounce, Complaint, Rendering Failure
  SEND = 'Send'
  REJECT = 'Reject'
  DELIVERY = 'Delivery'
  OPEN = 'Open'
  CLICK = 'Click'
  BOUNCE = 'Bounce'
  COMPLAINT = 'Complaint'
  RENDERING_FAILURE = 'Rendering Failure'
end

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

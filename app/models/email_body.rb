class EmailBody < ApplicationRecord
  belongs_to :email
  belongs_to :company, optional: true
end

class NotifyUser < ApplicationRecord
  belongs_to :parent, optional: true, polymorphic: true
  belongs_to :company, optional: true
end

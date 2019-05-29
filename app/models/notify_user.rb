class NotifyUser < ApplicationRecord
  belongs_to :parent, optional: true, polymorphic: true
  belongs_to :company, optional: true
  belongs_to :user, optional: true

  def as_json
    {
      id: self.id,
      email: self&.user&.email
    }
  end
end

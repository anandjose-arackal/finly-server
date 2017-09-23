class BankTransfer::Users::Count < BankTransfer::Users::Base

  attr_accessor :users_count

  def authorized_user_types
    [:vendor_payments_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init

  end

  def validate

  end

  def process
    # insert logic here for teams once that has been implemented in vendor payments
    op = BankTransfer::Users::Index.(current_user, params)
    if op.success?
      self.users_count = op.users.count
    end
  end

  def success
    users_count
  end

end
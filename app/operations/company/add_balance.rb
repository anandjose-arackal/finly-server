# action that sends a confirmation email to ItzCash regarding
# the balance load.
# params:
#   amount: value of balance added
#   Reference ID: the transaction ID of the NEFT transfer
#   date: Date of the NEFT transfer
#   remarks: Optional remarks

class Coompany::AddBalance < Company::Base

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "Invalid input. Please try again"
    end
  end

  def authorized_user_types
    [:company_admin]
  end

  def init

  end

  def validate

  end

  def authorize

  end

  def process
    #sends mailer to itzCash informing them about the transfer

  end
end

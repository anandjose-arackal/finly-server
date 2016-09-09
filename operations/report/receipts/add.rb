# action to add a receipt to a report.
# params:
# report_id: id of the report to which the receipt needs to be added.

class Report::Receipts::Add < Report::Base

  attr_accessor :new_receipt_params, :receipt

  def authorized_user_types
    [:employee]
  end

  def init
    self.report = user.reports.find_by(id: params[:report_id])
    self.new_receipt_params = receipt_params
  end

  def authorize
    unless report and report.user_id == user.id
      raise_unauthorized_exception
    end
    unless report.open? or report.retracted?
      errors << 'Cannot attach receipt unless report is open or retracted'
      return false
    end
  end

  def process
    self.receipt = report.receipts.build(new_receipt_params)
    receipt.user = user
    unless receipt.save
      errors << receipt.errors.full_messages
    end
  end

  def retrieve
    if is_success?
      return receipt
    else
      return false
    end
  end
end
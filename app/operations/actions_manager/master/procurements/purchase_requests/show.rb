class ActionsManager::Master::Procurements::PurchaseRequests::Show < ActionsManager::Master::Base

  register_handle :purchase_request_show
  register_actions [ :save_btn, :submit, :retract, :reject, :approve, :take_control, :delete_pr_line_item ]

  def initialize(user=nil, params=nil)
    super
    result = Procurements::PurchaseRequests::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.purchase_request = result.purchase_request
  end

  def save_btn
    true
  end

  def submit
    true
  end

  def retract
    true
  end

  def reject
    true
  end

  def approve
    true
  end

  def take_control
    true
  end

  def delete_pr_line_item
    true
  end


end
class ActionsManager::Master::PaymentAgreements::Show < ActionsManager::Master::Base

  register_handle :payment_agreement_show
  register_actions [ :edit_btn, :submit, :retract, :reject, :approve, :unapprove, :take_control, :return_control ]


  def edit_btn
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

  def unapprove
    true
  end

  def take_control
    true
  end

  def return_control
    true
  end

end
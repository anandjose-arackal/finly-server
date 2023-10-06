# This is to send email when `SendInvoiceEmailOnUtrUpdateToggle` set to `true`
# which means email should trigger only when UTR number has been updated

class Event::EInvoice::UtrUpdate < Event::EInvoice::Credit
  def validate
    super
    unless payment&.utr.present?
      add_message :error, 'Bank reference number not found'
      return
    end
  end

  def set_notification(user)
    # overiding this method here because notifications have already been set
    # when user clicked on `mark as credited` button even if the mailer was off
    # and did not sent any email when `mark as credited` was clicked
  end

  def allow_mailer(user, configuration, which_super: nil)
    # using which_super so that `Event::EInvoice::UtrUpdate#allow_mailer` can call `Event::EInvoice::Base#allow_mailer` directly

    if SendInvoiceEmailOnUtrUpdateToggle.new(user).enabled? # email should be sent on UTR updation only
      super(user, configuration, which_super: Event::EInvoice::Base.name) # calling `super` because email should be sent at the time of `UTR updation`
    else
      false # returning `false` so that it should not send email at the time of `UTR updation`
    end
  end

end

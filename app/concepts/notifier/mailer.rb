# Mandatory
# to, subject, :body_header, :template, :

class Notifier::Mailer < Notifier::API


  set :from, "noreply@finly.io"
  set :subject, "Finly Notification"
  set :body_header, "New Notification from Finly"
  set :template, ""

  def permissions(ctx, options)
    true
  end

  def prepare(options, params:, current_user:, **)
    super
  end

  def validate(ctx, options)
    true
  end

  def dispatch(options, payload:, **)
    ap payload
    # Notifier::Mailer.dispatch(payload)
    true
  end

end
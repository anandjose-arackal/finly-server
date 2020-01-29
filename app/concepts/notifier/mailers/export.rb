class Notifications::Mailers::Documents < Notifications::Mailer

  schema do
    params do
      required(:model).filled
      required(:event_name).filled
      # required(:event_name).hash do
      #   required(:template).filled(inclusion?: %w(template_1, template_2))
      # end
    end
  end

  recipients do |user, params|
    user
  end

  set :document do |user, params|
    params[:model]
  end

  set :event_name do |user, params|
    params[:event_name]
  end

  set :to do |user, params|
    user.email
  end

  set :cc do |user, params|
    params[:cc]
  end

  set :bcc do |user, params|
    params[:bcc]
  end

  set :title do |user, params|
    params[:title] || "Finly Notification"
  end

  set :subject do |user, params|
    params[:subject] || "Notification from Finly"
  end

  set :template, 'default_template'

  step :check


  def check(ctx, options)
    true
  end
end
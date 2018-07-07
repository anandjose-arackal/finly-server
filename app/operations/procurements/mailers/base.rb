class Procurements::Mailers::Base < BaseOperation
  attr_accessor :mailer_params

  def init
    mail

  end

  def validate

  end

  def process

  end

  def success
    params[:mailer] = mailer
    Procurements::Mailers::Base::MailerPresenter.new(user, params, messages)
  end

  class Procurements::Mailers::Base::MailerPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :mailer

    def init

    end
  end
end
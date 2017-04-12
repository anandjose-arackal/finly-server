class Payment::Process < BaseOperation
  attr_accessor :payment

  def pre_validate

  end

  def init

  end

  def validate

  end

  def process

  end

  def success
    params[:payment] = self.payment
    Payment::Process::SuccessPresenter.new(user, params, messages)
  end

  class Payment::Process::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment

    def init
      self.payment = params[:payment]
    end
  end

end
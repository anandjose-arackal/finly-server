class Settlement::Payment::Base

  class Settlement::Payment::Base::Presenter < Settlement::Base::BasePresenter
    attr_accessor :payment

    def initialize(user, params)
      super(user, params)
      self.payment = params[:payment]
    end
  end
end
class CustomField::Base < BaseOperation

  def self.call(params)
    self.new(params).run
  end

  def initialize(params)
    super(nil, params)
  end


  # def success
  #   CustomField::Base::SuccessPresenter.new(params)
  # end
  #
  # class CustomField::Base::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
  #   attr_accessor :params
  #
  #   def initialize(params)
  #     super(nil, params)
  #   end
  #
  # end

end
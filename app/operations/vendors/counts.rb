class Vendors::Counts < Vendors::Base
  attr_accessor :data

  def init
    vendors_index_op = Vendors::Index.(user, params)

    if vendors_index_op.success?
      self.data = vendors_index_op.get_counts
    end
  end

  def validate
  end

  def success
    params[:data] = self.data
    Vendors::Counts::CountsPresenter.new(user, params, messages)
  end

  class Vendors::Counts::CountsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data

    def init
      self.data = params[:data]
    end
  end
end
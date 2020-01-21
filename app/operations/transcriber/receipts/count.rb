class Transcriber::Receipts::Count < Transcriber::Base

  attr_accessor :count

  class Transcriber::Receipts::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:count]
    end

  end

  def process
    op = Transcriber::Receipts::Index.(user, params)
    if op.success?
      self.count = op.receipts.group('receipts.id').count&.count
    else
      add_message :error, op.messages[:error]
    end
  end

  def success
    params[:count] = self.count
    Transcriber::Receipts::Count::CountPresenter.new(user, params, messages)
  end
end
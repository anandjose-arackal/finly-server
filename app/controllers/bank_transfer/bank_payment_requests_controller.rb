class BankTransfer::BankPaymentRequestsController < ApplicationController

  def show

  end

  def create

  end

  def index

  end

  def parse_file

  end

  def process

  end

  def update
    update_handler(params[:type])
  end

  private

  def update_handler(type)
    if type.nil?
      respond response: :failure, message: "Invalid request"
      return
    end

    case type
      when 1
        # i.e. update of summary
      when 2
        # i.e. update of payment items
      when 3
        # i.e. update of attachments
      else
        # do nothing?
    end
  end
end


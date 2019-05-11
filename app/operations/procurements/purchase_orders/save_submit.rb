# This operation would save and then submit the PO in one API call

class Procurements::PurchaseOrders::SaveSubmit < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :flag_save, :flag_submit

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
    self.flag_save = false
    self.flag_submit = false
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end

  end

  def process

    call_save(params)
    return unless self.flag_save    
    call_submit(params)

  end

  def success
    params[:flag_save] = self.flag_save
    params[:flag_submit] = self.flag_submit
    Procurements::PurchaseOrders::SaveSubmit::SuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:flag_save] = self.flag_save
    params[:flag_submit] = self.flag_submit
    Procurements::PurchaseOrders::SaveSubmit::FailurePresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::SaveSubmit::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :flag_save, :flag_submit

    def init
      self.flag_save = params[:flag_save]
      self.flag_submit = params[:flag_submit]
    end 
  end

  class Procurements::PurchaseOrders::SaveSubmit::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter
    attr_accessor :flag_save, :flag_submit

    def init
      self.flag_save = params[:flag_save]
      self.flag_submit = params[:flag_submit]
    end 
  end

  private

  def call_save(params)
    op = Procurements::PurchaseOrders::Update.(user, params)

    op.messages.keys.each do |key|
      add_message key, op.messages[key]      
    end

    self.flag_save = (has_errors?) ? false : true
  end

  def call_submit(params)    
    op = Procurements::PurchaseOrders::Submit.(user, params)

    op.messages.keys.each do |key|
      add_message key, op.messages[key]      
    end

    self.flag_submit = (has_errors?) ? false : true
  end

end

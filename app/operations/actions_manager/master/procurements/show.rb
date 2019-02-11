class ActionsManager::Master::Procurements::Show < ActionsManager::Master::Base

  register_handle :procurements_show
  validate :input
  register_actions [:add_document]

  def initialize(user=nil, params={})
    super
    result = ::Procurements::PurchaseOrders::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.purchase_order = result.purchase_order
  end

  # alias_method :purchase_order, :input

  def add_document
    (purchase_order.approved? || purchase_order.auto_approved?) && (user_in_level? || document_owner?)
  end

  def document_owner?
    purchase_order.user_id.eql?(user.id)
  end

  def user_in_level?
    level = purchase_order.level
    amount = purchase_order.balance_amount.value rescue 0
    level.present? ? level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include?(user.id) : false
  end

end
class Dashboard::VendorPayments::Grns < Dashboard::VendorPayments::Base
  attr_accessor :procurements

  def init
    self.procurements = Procurements::Index.(user, params).procurements
  end

  def success
    params[:procurements] = self.procurements
    Dashboard::VendorPayments::Grns::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::Grns::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :procurements, :counts

    has_scope :filter_procurement_type
    has_scope :filter_status_tags

    def init
      self.procurements = params[:procurements]
      self.procurements = apply_scopes(self.procurements, {filter_procurement_type: 'purchase_order'})
      self.counts = []

      if user.is_goods_receiver?
        goods_receiver_data = {
          type: 'goods_receiver',
          data: [
            {
              title: "Total POs Awaiting Shipments",
              count: apply_scopes(procurements, {filter_status_tags: [7]})&.count
            }
          ]
        }

        self.counts.push(goods_receiver_data)
      end
    end
  end
end
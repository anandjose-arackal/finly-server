class Invoicing::InventoryLineItem::Search < Invoicing::InventoryLineItem::Base

  attr_accessor :term, :search_results

  class Invoicing::InventoryLineItem::Search::SearchResultsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :search_results

    def init
      self.search_results = params[:search_results]
    end
  end

  def init
    self.term = params[:term]
  end

  def process
    self.search_results = user.company.inventory_line_items.search(self.term)
  end

  def success
    params[:search_results] = self.search_results
    Invoicing::InventoryLineItem::Search::SearchResultsPresenter.new(user, params, messages)
  end
end
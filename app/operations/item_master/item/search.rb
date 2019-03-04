class ItemMaster::Item::Search < ItemMaster::Item::Base

  attr_accessor :term, :search_results

  class ItemMaster::Item::Search::SearchResultsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :search_results

    def init
      self.search_results = params[:search_results]
    end
  end

  def init
    self.term = params[:term]
    params[:search] = params[:term]
  end

  def process
    search_results_op = ItemMaster::Item::Index.(user, params)
    self.search_results = search_results_op.inventory_line_items
  end

  def success
    params[:search_results] = self.search_results
    ItemMaster::Item::Search::SearchResultsPresenter.new(user, params, messages)
  end
end
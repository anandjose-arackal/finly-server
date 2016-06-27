class BaseService
  attr_accessor :errors

  def initialize
    @errors = Container.new
  end

  class Container
    attr_accessor :items

    def initialize
      @items = Array.new
    end

    def add(item)
      @items << item
    end

    def clear
      @items.clear
    end

    def blank?
      @items.blank?
    end
  end
end
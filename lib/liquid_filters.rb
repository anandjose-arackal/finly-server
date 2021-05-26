module LiquidFilters

  def first_item(input) # will be available as the "first_item" filter
    array = input.split(',')
    array.first rescue ''
  end

  def second_item(input) # will be available as the "second_item" filter
    array = input.split(',')
    array.second rescue ''
  end

  def third_item(input) # will be available as the "third_item filter
    array = input.split(',')
    array.third rescue ''
  end

  def fourth_item(input) # will be available as the "fourth_item filter
    array = input.split(',')
    array.fourth rescue ''
  end
  
  def fifth_item(input) # will be available as the "fifth_item" filter
    array = input.split(',')
    array.fifth rescue ''
  end

  def sixth_item(input) # will be available as the "fifth_item" filter
    array = input.split(',')
    array[6] rescue ''
  end

  def seventh_item(input) # will be available as the "fifth_item" filter
    array = input.split(',')
    array[7] rescue ''
  end

  def eighth_item(input) # will be available as the "fifth_item" filter
    array = input.split(',')
    array[8] rescue ''
  end

  def ninth_item(input) # will be available as the "fifth_item" filter
    array = input.split(',')
    array[9] rescue ''
  end
  def tenth_item(input) # will be available as the "fifth_item" filter
    array = input.split(',')
    array[10] rescue ''
  end


end
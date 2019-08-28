class AmountUtils

  def self.format(value, options = {})
    options = {} if options.nil?
    return options[:placeholder] if value.nil?
    currency = options[:currency] || Currency.currency_for(:INR)
    symbol = currency.symbol || currency.country_code
    "#{symbol}#{value}"
  end

	def self.to_words(num)
		return '' if num.blank?
		numbers(num) + decimal(num)
	end

	def self.decimal(num)
		decimal = (BigDecimal(num.to_s).frac * 100).to_i
		paise = ' and '
		if decimal == 0
			paise += 'zero'
		elsif decimal <= 20
			paise += numbers(decimal)
		else
			rem = decimal % 10
			paise += [ numbers(decimal - rem), numbers(rem) ].join(' ')
		end
		paise += ' paise only'
	end

	def self.numbers(int)
	  numbers_to_name = {
	      10000000 => "crore",
	      100000 => "lakh",
	      1000 => "thousand",
	      100 => "hundred",
	      90 => "ninety",
	      80 => "eighty",
	      70 => "seventy",
	      60 => "sixty",
	      50 => "fifty",
	      40 => "forty",
	      30 => "thirty",
	      20 => "twenty",
	      19=>"nineteen",
	      18=>"eighteen",
	      17=>"seventeen",
	      16=>"sixteen",
	      15=>"fifteen",
	      14=>"fourteen",
	      13=>"thirteen",
	      12=>"twelve",
	      11 => "eleven",
	      10 => "ten",
	      9 => "nine",
	      8 => "eight",
	      7 => "seven",
	      6 => "six",
	      5 => "five",
	      4 => "four",
	      3 => "three",
	      2 => "two",
	      1 => "one"
	    }
	  int = int.to_i
	  return '' if int <= 0
	  str = ""
	  numbers_to_name.each do |num, name|
	    if int == 0
	      return str
	    elsif int.to_s.length == 1 && int/num > 0
	      return str + "#{name}"
	    elsif int < 100 && int/num > 0
	      return str + "#{name}" if int%num == 0
	      return str + "#{name} " + numbers(int%num)
	    elsif int/num > 0
	      return str + numbers(int/num) + " #{name} " + numbers(int%num)
	    end
	  end
	end

end
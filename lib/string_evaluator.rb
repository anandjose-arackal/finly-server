class ExpressionEvaluator < Parslet::Parser

  # # Single character rules
  # rule(:lparen)     { str('(') >> space? }
  # rule(:rparen)     { str(')') >> space? }
  # rule(:comma)      { str(',') >> space? }
  #
  # rule(:space)      { match('\s').repeat(1) }
  # rule(:space?)     { space.maybe }
  #
  # # Things
  # rule(:integer)    { match('[0-9]').repeat(1).as(:int) >> space? }
  # rule(:identifier) { match['a-z'].repeat(1) }
  # rule(:operator)   { match('[+]') >> space? }
  #
  # # Grammar parts
  # rule(:sum)        { integer.as(:left) >> operator.as(:op) >> expression.as(:right) }
  # rule(:arglist)    { expression >> (comma >> expression).repeat }
  # rule(:funcall)    { identifier.as(:funcall) >> lparen >> arglist.as(:arglist) >> rparen }
  #
  # rule(:expression) { funcall | sum | integer }
  # root :expression

  # Single character rules
  rule(:text) { match['a-z%,-'].repeat(1) }
  rule(:text?) { text.maybe }
  rule(:string) { match['a-z'].repeat(1) }
  rule(:space)      { match('\s').repeat(1) }
  rule(:space?)     { space.maybe }
  rule(:curly_open)     { str('{') >> space? }
  rule(:curly_close)     { str('}') >> space? }
  rule(:lparen)     { str('(') >> space? }
  rule(:rparen)     { str(')') >> space? }

  # Grammar parts
  rule(:params) { lparen >> text.as(:args) >> rparen }
  rule(:function) { string.as(:method) >> params }
  rule(:equation) { curly_open >> function >> curly_close }

  rule(:expression) { (text.as(:text) | equation.as(:equation) | (text.as(:text) >> equation.as(:equation))).repeat(0) }
  root :expression

end
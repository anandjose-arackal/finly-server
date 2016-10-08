Handlebars.registerHelper('if_eq', function(a, b, opts) {
  if (a == b) {
    return opts.fn(this);
  } else {
    return opts.inverse(this);
  }
});

Handlebars.registerHelper('if_not_eq', function(a, b, opts) {
  if (a != b) {
    return opts.fn(this);
  } else {
    return opts.inverse(this);
  }
});

Handlebars.registerHelper('increment', function(a, b){
  return parseInt(a) + b;
})

Handlebars.registerHelper('add', function(){
  var args = [].slice.apply(arguments);
  var opts = args.pop();

  var fn = opts.fn;
  var total = 0;
  for(var i = 0; i < args.length; ++i){
    if(typeof args[i] !== 'undefined'){
      total = total + parseInt(args[i]);
    }
  }

  return total;
})

Handlebars.registerHelper("switch", function(value, options) {
    this._switch_value_ = value;
    var html = options.fn(this); // Process the body of the switch block
    delete this._switch_value_;
    return html;
});

Handlebars.registerHelper("case", function(value, options) {
    if (value == this._switch_value_) {
        return options.fn(this);
    }
});

// Handlebars.registerHelper("default", function(options) {
//     if (!this._switch_break_) {
//         return options.fn(this);
//     }
// });

Handlebars.registerHelper('if_all', function() {
  var args = [].slice.apply(arguments);
  var opts = args.pop();

  var fn = opts.fn;
  for(var i = 0; i < args.length; ++i) {
    if(args[i])
      continue;
    fn = opts.inverse;
    break;
  }
  return fn(this);
});

Handlebars.registerHelper('ifCond', function (v1, operator, v2, options) {
  //access actual object by ../ inside ifCond
  switch (operator) {
    case '==':
      return (v1 == v2) ? options.fn(this) : options.inverse(this);
    case '===':
      return (v1 === v2) ? options.fn(this) : options.inverse(this);
    case '<':
      return (v1 < v2) ? options.fn(this) : options.inverse(this);
    case '<=':
      return (v1 <= v2) ? options.fn(this) : options.inverse(this);
    case '>':
      return (v1 > v2) ? options.fn(this) : options.inverse(this);
    case '>=':
      return (v1 >= v2) ? options.fn(this) : options.inverse(this);
    case '&&':
      return (v1 && v2) ? options.fn(this) : options.inverse(this);
    case '||':
      return (v1 || v2) ? options.fn(this) : options.inverse(this);
    default:
      return options.inverse(this);
  }
});


//Set a variable
Handlebars.registerHelper('setVar', function(varName, varValue, options){
  options.data.root[varName] = varValue;
});


//Find percentage
Handlebars.registerHelper('percentage', function(a, b){
  return parseInt(parseFloat(a) / parseFloat(b) * 100);
})









require 'dm-core'
DataMapper.setup(:default, "appengine://auto")

require 'extlib'
%w(Item Base).each do |model|
  autoload model.to_sym, "model/#{model.snake_case}"
end
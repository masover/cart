require 'dm-core'
DataMapper.setup(:default, "appengine://auto")
autoload :Item, 'model/item'
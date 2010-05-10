class Item
  include Base
  
  property :name, String, :required => true
  property :description, Text
  property :stock, Integer, :default => 0
end
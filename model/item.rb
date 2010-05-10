class Item
  include DataMapper::AppEngineResource
  
  property :name, String, :required => true
  property :description, Text
  property :stock, Integer, :default => 0
  
  def to_csv
    "[#{[name, description, stock].join ','}]"
  end
  alias to_param id
end
class Item
  include DataMapper::AppEngineResource
  
  property :name, String, :required => true
  property :description, Text
  property :stock, Integer, :default => 0
  
  def to_csv
    "[#{[name, description, stock].join ','}]"
  end
  alias to_param id
  
  def self.from_param param
    id = if param.kind_of? String
      com.google.appengine.api.datastore.KeyFactory.stringToKey param
    else
      param
    end
    get id
  end
end
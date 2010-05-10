module Base
  def self.included klass
    klass.class_eval do 
      include DataMapper::AppEngineResource
      extend ClassMethods
    end
  end
  
  module ClassMethods
    def from_param param
      id = if param.kind_of? String
        AppEngine::Datastore::Key.new param
      else
        param
      end
      get id
    end
  end
  
  def to_csv
    "[#{[name, description, stock].join ','}]"
  end
  def to_param
    id
  end
end
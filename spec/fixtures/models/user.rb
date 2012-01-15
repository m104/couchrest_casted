class User < CouchRest::Model::Base
  use_database DB

  property :name, :accessible => true
  validates_length_of :name, :minimum => 4, :maximum => 20
end


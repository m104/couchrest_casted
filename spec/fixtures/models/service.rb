class Service < CouchRest::Model::Base
  use_database DB

  property :name
  validates_length_of :name, :minimum => 4, :maximum => 20
end

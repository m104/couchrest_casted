# CouchRest Casted: Enable polymorphic CouchDB queries

Pull properly-casted documents from a CouchDB/CouchBase database, directly from
CouchRest queries. Uses CouchRest::Model as a modelling framework.

## Installation

(depends on `couchrest` and `couchrest_model` gems)

### Gem

    $ gem install couchrest_casted

### Bundler

Bundler users can add this line to their Gemfile:

    gem 'couchrest_casted'

## Usage

The following is a simple example of using a CouchDB view to load documents
of different CouchRest::Model classes, casted automatically:

    require 'rubygems'
    require 'couchrest_casted'

    # connect to the CouchDB server
    cr = CouchRest.new('http://localhost:5984')
    DB = cr.database('casted_test')
    # create the database
    DB.recreate!

    # define a couple of similar document models
    class Service < CouchRest::Model::Base
      use_database DB
      property :name
    end

    class Person < CouchRest::Model::Base
      use_database DB
      property :name
    end

    # create some documents (services and users)
    ['Socialiting', 'Window Washing',
     'Keynoting', 'Table Architecture'].each do |name|
      Service.new(:name => name).save!
    end

    ['Zark Muckerberg', 'Gill Bates',
     'Jeve Stobs', 'Ellarry Lison'].each do |name|
      Person.new(:name => name).save!
    end

    # a simple view that splits the 'name' field
    # into words and emits one row per word
    DB.save_doc({
      "_id" => "_design/generic",
      :views => {
        :by_word => {
          :map => <<-JS
            function(doc) {
              if (doc.name && doc.name.length > 0) {
                var words = doc.name.split(/\\W/);
                words.forEach(function(word){
                  if (word.length > 0) emit(word, 1);
                });
              }
            }
          JS
        } } })

    # query the generic view
    rows = DB.casted_view('generic/by_word')['rows']

    # each returned document should be casted as the
    # correct CouchRest::Model class
    rows.each do |row|
      doc = row['doc']
      key = row['key']
      value = row['value']
      puts [doc.id, doc.class.to_s, doc.name, key, value].join(', ')
    end

## Contact

Bugs, suggestions, and such can be posted to [https://github.com/m104/couchrest_casted/issues](https://github.com/m104/couchrest_casted/issues).



require File.expand_path("spec_helper", File.dirname(__FILE__))
require File.expand_path('models/service', FIXTURE_PATH)
require File.expand_path('models/user', FIXTURE_PATH)

describe 'Multi-class queries' do
  before(:all) do
    reset_test_db!

    # load the test cases

    ['Lawncare', 'Elephant Training', 'Cheese Tasting',
     'Acrobatic Training', 'Firehydrant Painting',
     'Clock Winding', 'Remote Finding', 'Chocolate Tasting',
     'Rabbit Training', 'Propeller Winding'].each_with_index do |name, index|
      Service.new(:id => "service-#{index}",:name => name).save!
    end

    ['Brenda Pardone', 'Wendel Covington', 'Bradly P. Buttersby',
     'Frox', 'Jenny Hammersmithe', 'Shu Lao Chun', 'Waldo',
     'Michael Pardone', 'Bradly Hammersmithe',
     'The Other Frox'].each_with_index do |name, index|
      User.new(:id => "user-#{index}", :name => name).save!
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
        }
      }
    })
  end

  describe 'from reference #get' do
    it 'should return nil when document is not found' do
      doc = nil
      expect { 
        doc = DB.get('not-a-doc')
      }.to raise_error(RestClient::ResourceNotFound)
      doc.should be_nil
    end

    it 'should return a CouchRest::Document object to represent a document' do
      doc = DB.get('service-4')
      doc.should be_an_instance_of(CouchRest::Document)
    end
  end

  describe 'from #casted_get' do
    it 'should return nil when document is not found' do
      doc = nil
      expect {
        doc = DB.casted_get('not-a-doc')
      }.to raise_error(RestClient::ResourceNotFound)
      doc.should be_nil
    end

    it 'should return a casted CouchRest::Model object to represent a document' do
      doc = DB.casted_get('service-4')
      doc.should be_an_instance_of(Service)
      doc.should be_a_kind_of(CouchRest::Model::Base)
    end
  end

  describe 'from reference #view' do
    before(:all) do
      @all_rows = DB.view('generic/by_word', :include_docs => true)['rows']

      @no_rows  = DB.view('generic/by_word',
                           :include_docs => true,
                           :startkey => 'Zanzibar',
                           :endkey => 'Zapfino')['rows']
    end

    it 'should return an Array' do
      @all_rows.should be_an_instance_of(Array)
    end

    it 'should return all of the documents' do
      @all_rows.size.should eq(40)
    end

    it 'should return documents as Hashes' do
      @all_rows.each do |row|
        doc = row['doc']
        doc.should be_an_instance_of(Hash)
      end
    end

    it 'should work even when no documents are returned' do
      @no_rows.should be_an_instance_of(Array)
      @no_rows.size.should eq(0)
    end
  end


  describe 'from #casted_view' do
    before(:all) do
      @all_rows = DB.casted_view('generic/by_word')['rows']

      @no_rows  = DB.casted_view('generic/by_word',
                                  :startkey => 'Zanzibar',
                                  :endkey => 'Zapfino')['rows']
    end

    it 'should return an Array' do
      @all_rows.should be_an_instance_of(Array)
    end

    it 'should see all documents' do
      @all_rows.size.should eq(40)
    end

    it 'should properly cast documents into CouchRest::Model objects' do
      @all_rows.each do |row|
        doc = row['doc']
        doc.should be_an_instance_of(doc['type'].constantize)
      end
    end

    it 'should work even when no documents are returned' do
      @no_rows.should be_an_instance_of(Array)
      @no_rows.size.should eq(0)
    end

    it "should keep non-CouchRest::Model documents cast as Hashes" do
      DB.save_doc({
        '_id' => 'other-fbenvolio',
        'name' => 'Francis Benvolio'
      })

      rows = DB.casted_view('generic/by_word',
                            :startkey => 'Francis',
                            :endkey => 'Francis')['rows']
      rows.size.should eq(1)
      doc = rows.first['doc']
      doc['name'].should eq('Francis Benvolio')
      doc['_id'].should eq('other-fbenvolio')
      doc.should be_an_instance_of(Hash)
    end
  end

end

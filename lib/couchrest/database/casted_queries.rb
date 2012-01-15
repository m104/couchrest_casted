module CouchRest
  class Database
    # Just like +view+, but automatically includes the documents
    # in the response and casts each document as a CouchRest::Model
    # class, if possible.
    #
    # Currently, +casted_view+ doesn't support given blocks.
    def casted_view(name, params = {})
      # force the DB response to include documents
      params[:include_docs] = true
      response = view(name, params)
      rows = response['rows']
      return response unless rows

      response['rows'] = rows.map do |row|
        doc = row['doc']
        type = doc['couchrest-type'] || doc['type']
        if type
          klass = type.constantize
          if klass.respond_to? :build_from_database
            row['doc'] = klass.build_from_database(doc)
          end
        end
        row
      end

      response
    end

    # Just like +get+, but casts the returned document as a
    # CouchRest::Model, if there is a matching class available
    #
    # Currently, +casted_get+ doesn't support given blocks.
    def casted_get(id, params = {})
      doc = get(id, params)
      return nil unless doc
      return doc unless type = doc['couchrest-type'] || doc['type']
      klass = type.constantize
      return doc unless klass.respond_to? :build_from_database
      klass.build_from_database(doc)
    end

  end
end

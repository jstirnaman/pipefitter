# Fixlr's Worlcat wrapper from worldcat-api with a few additional params
module Worldcat

  class Client
    include HTTParty
    
    format :xml

    base_uri 'http://www.worldcat.org/webservices/catalog'

    def initialize(wskey)
      self.class.default_params :wskey => wskey
      self.class.default_params :servicelevel => 'full'
      self.class.default_params :recordSchema => 'info=srw/schema/1/marcxml'
    end

    # Perform an SRU search of the Worldcat database and returns results.
    def search(query, options = {})
      options.merge!({:query => query})
      self.class.get("/search/sru", :query => options)
    end

    # Get a single bibliographic record
    def get_record(id, options = {})
      id = format_id_param(id)
      self.class.get("/content/#{id}", :query => options)
    end

    # Get information about the libraries that indicate they hold the item.
    def get_locations(id, options = {})
      id = format_id_param(id)
      self.class.get("/content/libraries/#{id}", :query => options)
    end

    # Get the Library Catalog URL for a specific item at OCLC libraries.
    def get_catalog_urls(id, oclcsymbol, options = {})
      options.merge!(:oclcsymbol => Array(oclcsymbol).join(','))
      get_locations(id, options)
    end

    # Get formatted bibliographic citations, in an HTML encoded form suitable
    # for incorporation into a web application.
    def get_citations(id, options = {})
      id = format_id_param(id)
      self.class.get("/content/citations/#{id}", :query => options)
    end

    private

    def format_id_param(id)
      Array(id).join('/')
    end
  end
end
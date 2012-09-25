class ResourceProxy

  include Ezproxy #api/ezproxy.rb

  def initialize
		if API_CONFIG['EZPROXY']['BASE_URL']
			Ezproxy::Client.base_uri(API_CONFIG['EZPROXY']['BASE_URL'])
		end
    @client = Ezproxy::Client.new
  end
  
  def list
    @client.list
  end
  
  def search(query)
  #Returns search results for query, e.g. search("pubmed")
    #Httparty response object
    @q = @client.search(query)
  end
   
  def recordset
  # Returns a hash of records.
    get_recordset(response_parsed)
  end
  
  def response_parsed
  # Returns Httparty parsed_response hash.
    @q.parsed_response
  end
  
  def response_raw
  # Returns unparsed response object from Httparty.
    @q.response.body
  end
 
end
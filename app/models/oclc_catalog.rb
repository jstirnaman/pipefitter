class OclcCatalog
  include Worldcat #api/worldcat.rb
  
  def client
    Worldcat::Client.new(API_CONFIG['OCLC']['API_KEY'])
  end
  
  def search(query)
    #Httparty response object
    @q = client.search(query)
  end
  
  def response_parsed
    @q.parsed_response
  end
  
  def response_raw
    @q.response.body
  end
  
  def recordset
  # Return a hash of records
    get_recordset(response_parsed)
  end
  
  def get_recordset(response)
  # Find a hash of records in the response object
    if response["searchRetrieveResponse"]
      records = response["searchRetrieveResponse"]["records"]
    end
  end
  
  def marcxml
    xmldoc = Nokogiri::XML::Document.parse(response_raw)
    # We only want a collection of records so match the <records> element and return the node
    records = xmldoc.css('records').to_s
  end
  
  def read
    MARC::XMLReader.nokogiri!
    reader = MARC::XMLReader.new(StringIO.new(marcxml))
    reader.each {|r| r.to_marc}
  end
  
  
end
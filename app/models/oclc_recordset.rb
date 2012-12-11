class OclcRecordset
  attr_accessor :recordset, :response_raw
  include Worldcat #api/worldcat.rb
  
  def initialize(options = {})
    
    @client = Worldcat::Client.new(API_CONFIG['OCLC']['API_KEY'])
    recordset
    case
      when options['i']
      @response = @client.get_record(options['i'])
      recordset = @response.parsed_response
      when options['q']
      @response = @client.search(options['q'])
      recordset = get_recordset(@response.parsed_response)
    end
    @response_raw = @response.body
    @recordset = recordset #Returns hash of records.  
  end
  
  def search(query)
  #Returns search results for query, e.g. search("pubmed")
    #Httparty response object
    @q = @client.search(query)
  end
  
  def to_marcxml
  # Parses XML response and returns just the set of MARCXML records as an XML string.
    xmldoc = Nokogiri::XML::Document.parse(response_raw)
    records = xmldoc.css('record') # Returns Nodeset of record elements
    colldoc = Nokogiri::XML::Document.new()
    collnode = Nokogiri::XML::Node.new('collection',colldoc) # Creates a new top-level collection element
    collnode << records
    colldoc << collnode
  end
  
  def get_recordset(response)
  # Find a hash of records in the response object
    if response["searchRetrieveResponse"]
      records = response["searchRetrieveResponse"]["records"]
    end
  end
  
# Example. No use yet.  
#   def read
#     MARC::XMLReader.nokogiri!
#     reader = MARC::XMLReader.new(StringIO.new(marcxml))
#     reader.each {|r| puts r.to_marc}
#   end
  
  
end
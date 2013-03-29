require 'nokogiri'

module Ditare

  class OclcRecordset
    include Worldcat #api/worldcat.rb
		attr_accessor :client, :recordset
		
		def initialize(query)
		  @client = Worldcat::Client.new(API_CONFIG['OCLC']['API_KEY'])
		  @recordset = find_all(query)
		end
		   
		def find_all(query)
			case
				when query[:i]
					@response = client.get_record(query[:i]).response.body
				when query[:q]
					# SRU response
					@response = client.search(query[:q]).response.body
			end
			xmldoc = Nokogiri::XML::Document.parse(@response)
			records = xmldoc.css('record') # Returns Nodeset of record elements
			to_marcxml(records)
		end
		
		def to_marcxml(records)
		# Converts a nodelist of <record> into a
		# MARCXML-like document: 
		# <collection><record>..</record></collection.
			colldoc = Nokogiri::XML::Document.new()
			# Add a root element named collection
			colldoc.root=colldoc.create_element('collection')
			# Add records from nodeset as child of the root element.
			colldoc
			colldoc.root << records.xpath('.//xmlns:record', {'xmlns' => "http://www.loc.gov/MARC21/slim"})
			colldoc
		end
  end  
end
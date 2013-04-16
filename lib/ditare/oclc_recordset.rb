require 'nokogiri'

module Ditare

  class OclcRecordset
    include Worldcat #api/worldcat.rb
		attr_accessor :client, :recordset, :query
		
		LANGUAGE = API_CONFIG['OCLC']['LANGUAGE']
		
		def initialize(query)
		  @query = query
		  @client = Worldcat::Client.new(API_CONFIG['OCLC']['API_KEY'])
		end
		   
		def find_all
			case
				when query[:i]
					client.get_record(query[:i]).response.body
				when query[:q]
					# SRU response
					client.search(query[:q]).response.body
			end
		end
		
		def to_record_nodeset
			xmldoc = Nokogiri::XML::Document.parse(find_all)
			xmldoc.css('record') # Returns Nodeset of record elements		
		end
		
		def to_marcxml(records = to_record_nodeset)
		# Converts a nodeset of <record> into a
		# MARCXML-like document: 
		# <collection><record>..</record></collection.
			colldoc = Nokogiri::XML::Document.new()
			# Add a root element named collection
			colldoc.root=colldoc.create_element('collection')
			# Add records from nodeset as child of the root element.
			record_nodes = records.xpath('.//xmlns:record', 
			                  {'xmlns' => "http://www.loc.gov/MARC21/slim"})
			record_nodes = record_nodes.empty? ? records.css('record') : record_nodes
			colldoc.root << record_nodes
			colldoc
		end
  end  
end
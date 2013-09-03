module SerialsSolutions
  module Openurl
		class Client
			include HTTParty
			attr_accessor :response
			
			format :xml
	    # See http://xml.serialssolutions.com/docs/360Link/v1.0/index.html for API docs.
			base_uri API_CONFIG['SERIALS_SOLUTIONS']['INSTITUTION_ID'] + '.openurl.xml.serialssolutions.com/openurlxml'
			
			def initialize(q)
				self.class.default_params :version => '1.0'
				@response = request(q)
			end
	
			def request(openurl_params, options = {})
			# Accepts hash of standard OpenURL parameters with 
			# key as SYMBOL and value as STRING, 
			# e.g. {:issn => '2218-2020'} or {:title => 'Anaesthesia Supplement'}
			# or {:pmid => '23211928'} or {:doi => '10.1016/j.jpeds.2012.10.003'} 
				options.merge!(:query => openurl_params)
				self.class.get("/", options)
			end
			
			def openurl_response
				response.parsed_response['openURLResponse']
			end
			
			def openurl_response_xml
				Nokogiri::XML::Document.parse(response.body)
			end
			
			def holdings?
				# From SS API docs:
				# When the metadata presented in an OpenURL query
				# corresponds to a single resource that the library 
				# has holdings for, there will be a single result 
				# element in the returned XML. If the library has 
				# no holdings for the referenced resource, there will 
				# be a single result element with no linkGroups element. 
				# When the metadata provided is ambiguous or not sufficient 
				# to allow us to distinguish among several resources, 
				# several results and their respective links and holdings 
				# data will be returned. This is true even when there are 
				# several resources that match the metadata but the 
				# library has no holdings for any of them. 
			  !(Nokogiri::XML::Document.parse(response.body)
				.xpath('//ssopenurl:linkGroups').empty?)
			end
			
			def all_holdings
        # Return all holdings, regardless of linkGroups containers.
				Nokogiri::XML::Document.parse(response.body)
				.xpath('//ssopenurl:linkGroup[@type="holding"]')
			end
		end
	end
end
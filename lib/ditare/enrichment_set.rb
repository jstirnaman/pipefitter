module Ditare
  include GData
  class EnrichmentSet
    attr_accessor :client, :recordset
    def initialize(options)
      @client = GData::Client.new(API_CONFIG['GOOGLE_DRIVE']['ONLINE_RESOURCES_SHEET'])
      @recordset = find_all(options[:field], options[:q])      
    end
    
		def find_all(field, query)
			
			# Accept string or regexp. If string, convert to regexp.
			query = query.class == Regexp ? query : %r/#{query}/i
			# Return an array of matching resources as GoogleDrive::ListRow objects
			#  #<GoogleDrive::ListRow {"database_name"=>"AccessMedicine", 
			#    "local_subjects"=>"Clinical Medicine; Basic Sciences", "oclc_id"=>"51502184"}>
			client.worksheet.select { |r| r[field].match(query) }
		end

  end
end
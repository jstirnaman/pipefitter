module Ditare
  include GData
  GOOGLE_SHEET_LOG = Rails.root.to_s + "/log/tmp/google_drive_last_updated.txt"

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
			client.worksheet.list.select { |r| r[field].match(query) }
		end
		
		def last_updated
		  File.open(GOOGLE_SHEET_LOG, "r") do |f|
		     Time.parse(f.readlines[0])
		  end		  
		end
		
		def changed?
		  # Compare the previous recorded timestamp in our log 
		  # with the current "updated" attribute of the worksheet.
		  compare = client.worksheet.updated <=> last_updated
		  if compare == 0  
		    true
		  else
		    false
		  end
		end
		
		def timestamp
		  # Record the last updated time of the worksheet.
		  File.open(GOOGLE_SHEET_LOG, "w") do |f|
		     f.puts client.worksheet.updated 
		  end		  
		end
  end
end
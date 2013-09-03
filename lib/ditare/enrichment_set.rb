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
		
		
		def to_oclc
			# Return a MarcRecordset containing a matching OCLC record for each entry in recordset."
			# Direct match on OCLC number ["oclc_id"]. Searching is too ambiguous, at least as
			# I was trying to do it.
		  mr_set = ''
		  recordset.each do |r|
		    #mr = Ditare::MarcRecordset.new(:oclc, {:q => 'srw.ti ALL ' + '"' + r[:database_name] + '"' })
					mr =  Ditare::MarcRecordset.new(:oclc, {:i => r["oclc_id"].to_i})
					marc_arr = []
					mr.read.each do |mrc|
						marc_arr << mrc.to_marc
					end
					unless marc_arr.empty?
						mr_set << marc_arr.first
					end
		  end
		  mr = Ditare::MarcRecordset.new(:local, ({}))
      mr.recordset = mr_set
      mr
		end
		
		def to_dublincore
		  # Construct a set of DC records for each entry in recordset.
		  mr_set = ''
		  dcdoc = Nokogiri::XML::Document.new
      dcdoc.root = Nokogiri::XML::Node.new('dc', dcdoc)
      dcdoc.root.add_namespace_definition('dc', 'http://purl.org/dc/terms')
		  recordset.each do |r|
		    dcrecord = Nokogiri::XML::Node.new('dc:resource', dcdoc)
		    #dcrecord.
		    #dcrecord.add_namespace()
		    dcrecord << '<dc:title>' + r["database_name"] + '</dc:title>'
		    dcrecord << '<dc:description>' + r["description"]  + '</dc:description>'
		    r["local_subjects"].split(';').each do |subject|
		      dcrecord << '<dc:subject>' +  subject  + '</dc:subject>'
		    end
		    dcrecord << '<dc:identifier>' +  r["url"]  + '</dc:identifier>'
		    dcrecord << '<dc:format>' + 'Online' + '</dc:format>'
		    dcrecord << '<dc:format>' + 'Electronic' + '</dc:format>'
		    #@TODO: Add access rights to enrichments.
		    #dcrecord << '<dc:accessRights>' + '</dc:accessRights>'
		    # Create an identifier from hash of content and length of name. Prepend it with OCLC symbol
		    # for distinguishing.
		    dcrecord << '<id>' + 'D' + API_CONFIG['OCLC']['LIBRARY'] + r["database_name"].hash.abs.to_s + '</id>'
        dcdoc.root << dcrecord
        dcdoc.xpath('.//*').each{|node| node['xmlns:dc'] = 'http://purl.org/dc/terms'}
		  end
		  mr = Ditare::MarcRecordset.new(:local, ({}))
      mr.recordset = dcdoc.to_xml
      mr
		end
		
		def to_marc
		# Construct a set of minimal MARC records for each entry in recordset.
		# If you want to retrieve OCLC records, use .to_oclc instead.
		  mr_set = ''
		  recordset.each do |r|
		    mrec = MARC::Record.new()
		    # Leader
		    # 001
		    mrec['001'] = 'D' + API_CONFIG['OCLC']['LIBRARY'] + r["database_name"].hash.abs.to_s
		    
		    # 003
		    # 005
		    # 008
		    # 040
		    # 245
		    # 256
		    # 260
		    # 300
		    # 5xx
		    mr_set << mrec.to_marc
		  end
		mr = Ditare::MarcRecordset.new(:local, ({}))
		mr.recordset = mr_set.to_marc
		mr
		end
  end
end
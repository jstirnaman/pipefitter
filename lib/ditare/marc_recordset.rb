require 'marc'

module Ditare
  
  class MarcRecordset
  # Mix in all the goodness of MARC gem.
  include MARC
		attr_accessor :reader, :recordset
		def initialize(recordsource = :oclc, options = {})
			# Accept a file, string, or api name.
			if recordsource == :oclc
				@reader = :marcxml
				@recordset ||= OclcRecordset.new(options).to_marcxml     
			end
		end
    
		def read
			if reader == :marcxml
				read_marcxml(recordset)
			else
				# Returns new MARC::Reader for the recordset.
				# All the MARC goodness is at your disposal.
					reader = Reader.new(File.expand_path(recordset, __FILE__))
					reader ||= Reader.new(StringIO.new(recordset))
			end
		end
	
		def read_marcxml(xmlcoll)
			MARC::XMLReader.nokogiri!
			xmldoc = xmlcoll.to_xml # Get string representation of the XML doc.
			MARC::XMLReader.new(StringIO.new(xmldoc))
		end  

		def export_file(filedesc = '')
			export_path = Rails.root.to_s + '/public/export/'
			filedesc = filedesc + '_' unless filedesc == ''
			export_path + self.class.to_s + '_' + filedesc + Time.now.strftime("%Y%m%d%H%M") + ".mrc"
		end
 
		 def proxieds
			# Returns array of record and matching proxy entry.
			proxy_list = Ezproxy::Client.new
			results = []
			read.each do |record|
				q = proxy_list.links({:text => %r/^#{record['245']['a'].strip}/i})
				unless q.empty?
					results << [record.to_marc, q]
				end
			end
			results
		end

		def proxied
			# Modified set of MARC-encoded records with proxied links in the 856.
			marc = []
			proxieds.each do |p|
			  reader = MARC::Reader.new(StringIO.new(p[0]))
			  reader.each do |r|
						r.append(MARC::DataField.new( '856', '4', '0', 
																				['u', p[1][0].href], 
																				['y', ('Connect to ' + r['245']['a'])]
																				)
										)
						marc << r
			  end
			end
			marc
		end
		
		def tags
			# Returns array of record and matching tagged entry.
			results = []
			read.each do |record|
				es = Ditare::EnrichmentSet.new({
				      :field => 'database_name',
				      :q => %r/^#{record['245']['a'].strip}/i
				      })
				unless es.recordset.empty?
					results << [record.to_marc, es.recordset]
				end
			end
			results
		end		
	
		def tagged
			# Returns a new set of MARC-encoded records enriched with local subjects and other local info.
			marc = []
			tags.each do |t|
			  reader = MARC::Reader.new(StringIO.new(t[0]))
			  reader.each do |r|
							subjects = t[1][0]["local_subjects"].split(';')
							subjects.each do |s|
								r.append(MARC::DataField.new( '650', '7', '0', 
																					['a', s.strip], 
																					['2', 'http://library.kumc.edu']
																					)
											)
							end
					marc << r
				end
      end
      marc
		end  
	
		def enriched
			# Perform all enrichments and export the file with the descriptor "_enriched_" in the name.
      @recordset = proxied
			mr = Ditare::MarcRecordset.new(:local, {})
      mr.tagged
      mr.to_marc_export("_enriched_")
		end
		
		def to_marc_export(out_file)
		  writer = Writer.new(out_file ||= export_file)
		  	writer.write(self)
			writer.close
		end
		
  end	 
end
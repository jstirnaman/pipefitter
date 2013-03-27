module MarcRecordset
  # Mix in all the goodness of MARC gem.
  include MARC
  include OclcRecordset
  
  class Recordset
		attr_accessor :reader, :recordset
		def initialize(recordsource = :oclc, options = {})
			# Accept a file, string, or api name.
			if recordsource == :oclc
				@reader = :marcxml
				@recordset = OclcRecordset.find_all(options)     
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
	
		def is_proxied?
			if @proxied.nil? || @proxied_results.size == 0
				false
			elsif @proxied.size > 0
				true
			end
		end 
	 
		def has_tagged_resource?
			if @selected.nil? || @selected.size == 0
				false
			elsif @selected.size > 0
				true
			end  
		end
	

		def export_file(filedesc = '')
			export_path = Rails.root.to_s + '/public/export/'
			filedesc = filedesc + '_' unless filedesc == ''
			export_path + self.class.to_s + '_' + filedesc + Time.now.strftime("%Y%m%d%H%M") + ".mrc"
		end
 
		 def has_proxied_resources
			# Returns array of record identifier (001) and matching proxy entry.
			proxy_list = ResourceProxy.new
			results = []
			read.each do |record|
				q = ResourceProxy.find_all(%r/^#{record['245']['a'].strip}/i)
				unless q.empty?
					results << [record['001'].value, q]
				end
			end
			@proxied = results
		end
	
		def has_tagged_resources
			# Returns array of record identifier (001) and matching tagged entry.
			results = []
			read.each do |record|
				q = SelectedResource.find_all(%r/^#{record['245']['a'].strip}/i)
				unless q.empty?
					results << [record['001'].value, q]
				end
			end
			@tagged = results
		end

		def add_proxy_url(out_file)
			# Gets records that have matching proxy entry.
			# Writes a file containing the modified set of MARC-encoded records with proxied links in the 856.
			@proxied ||= has_proxied_resources
			writer = Writer.new(out_file ||= export_file)
			read.each do |r|
				proxy_entry = @proxied.select {|p| p[0] == r['001'].value}.flatten
					unless proxy_entry.empty?  
						r.append(MARC::DataField.new( '856', '4', '0', 
																				['u', proxy_entry[1].href], 
																				['y', ('Connect to ' + r['245']['a'])]
																				)
										)
					end
				writer.write(r)
			end
			writer.close
		end
	
		def add_tags(out_file)
			# Gets records that have matching proxy entry.
			# Returns a new set of MARC-encoded records enriched with local subjects and other local info.
			@tagged ||= has_tagged_resources
			writer = Writer.new(out_file ||= export_file)
			read.each do |r|
				tagged_entry = @tagged.select {|t| t[0] == r['001'].value}.flatten
					unless tagged_entry.empty?
						subjects = tagged_entry[1]["local_subjects"].split(';')
						subjects.each do |s|
							r.append(MARC::DataField.new( '650', '7', '0', 
																				['a', s.strip], 
																				['2', 'http://library.kumc.edu']
																				)
										)
						end
					end
				writer.write(r)
			end
			writer.close
		end  
	
		def enrich
			# Perform all enrichments and export the file with the descriptor "_enriched_" in the name.
			out_file = export_file
			add_proxy_url(out_file)
			m = MarcRecordset.new(out_file)
			m.add_tags(export_file('enriched'))
		end 
  end
end
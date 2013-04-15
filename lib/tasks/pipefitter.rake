# Rake tasks for Pipefitter

namespace :pipefitter do
  desc 'Compares import file titles to holdings in link resolver knowledgebase.'
  task :report_eresource_holdings => :environment do
    puts "\n\n== Comparing title holdings in file with eresource holdings."
    begin
      unless ARGV[1].nil?
        path = ARGV[1]
        path = Rails.root.join(path)
        table = CsvReporter::Import.new(Rails.root.join(path))
        
        p table.data.size.to_s + " rows " + " in " + path.to_s
        p "with headers: " + table.data.headers.join(', ')

        holdings = []
        table.data.each do |row|
          q = {:issn => row[:issn]} unless row[:issn].nil?
          q ||= {:title => row[:title]}
          e = EResourceHolding.new(q)
          p q.to_s + "? " + e.kb_holdings.holdings?.to_s
          holdings << e.kb_holdings.holdings?.to_s
          sleep(0.3) # Throttle API requests; pause before processing next row.
        end
        # Fill a new local_holdings column with holdings array and write the file.
        table.data["local_holdings"]= holdings
        CsvReporter::Export.new("eresource_holdings", table.data)
      else
      puts "### ERROR - No file supplied ###"
      end
    rescue RuntimeError
      puts "### ERROR - Comparing eresource holdings ###"
    end
  end
  
  desc 'Fetches a MARC record for each resource in enrichments. 
        Enriches fetched MARC records with EZProxy link and enrichment data.
        pipefitter:enrich_marc[true] forces the task to run even if 
        Enrichments have not changed.'
  task :enrich_marc, [:force] => [:environment] do |t, args|
    puts "\n\n == Checking if enrichments source has changed."
    @es = Ditare::EnrichmentSet.new({:field => "database_name", :q => ".*"})
    if args[:force] or @es.changed?
      puts "\n\n == Force was set to " + args[:force].to_s
      puts "\n\n == Enrichments file changed? " + @es.changed?.to_s

      # Get an Ezproxy client ready for searching.
      ez = Ezproxy::Client.new
      # Enrich marc records for the EnrichmentSet
      @es.recordset.each do |e|
        # Find resources in EZProxy and return a hash for each resource.
        ez_marc = ez.with_marc({:text => e["database_name"]})
        unless ez_marc.first.nil?
					marc = ez_marc.first[:marc]
					marc.first.enrich({:enrichments_id => e["database_name"], 
					                   :proxied_text => e["database_name"]})
				end
				puts "\n\n == Exporting enriched file."
        marc.to_marc_export('pipefitter-enriched')  
      end
        
        # If resource not in EZProxy, find the best OCLC match using the available data.
        # If we have an OCLC record, enrich it and write the MARC result to a file. 

    else
      # Do nothing
    end
    
  end
end

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
        Accepts 2 arguments:
        pipefitter:enrich_marc[true] forces the task to run even if 
        Enrichments have not changed.
        pipefitter:enrich_marc[true|false, `path to list of bib record ids`]
        enriches the bib records specified in a list of record ids.'
  task :enrich_marc, [:force, :batch_ids] => [:environment] do |t, args|
    puts "\n\n == Checking if enrichments source has changed."
    @es = Ditare::EnrichmentSet.new({:field => "database_name", :q => ".*"})
    if args[:force] or @es.changed?
      puts "\n\n == Force was set to " + args[:force].to_s
      puts "\n\n == Enrichments file changed? " + @es.changed?.to_s
      
      if args[:batch_ids] and !args[:batch_ids].empty?
        puts "Reading batch file #{args[:batch_ids]}..."
        batch = IO.readlines(args[:batch_ids])
        batch = batch.map{|line| line.to_i unless line.to_i == 0}.compact
        
        puts "Attempting to fetch #{batch.size} records"
        mr = Ditare::MarcRecordset.new(:oclc, {})
        out_file = File.new(mr.export_file("_batch-enriched_"), "a")

        batch.each do |rec_id|
          begin
            puts "#### Next Record ####"
            puts "Record ID #{rec_id}"
            mrs = Ditare::MarcRecordset.new(:oclc, {:i => rec_id})
            mrs = mrs.enriched
            out_file.write(mrs.recordset)
          rescue StandardError => e
            puts e.inspect
          end     
        end
       
       puts "Finished!"
      
      end
        
        # If resource not in EZProxy, find the best OCLC match using the available data.
        # If we have an OCLC record, enrich it and write the MARC result to a file. 

    else
      # Do nothing
    end
    
  end

  desc 'Generates hits against EZProxy-configured resources.'
  task :acts_on_ezproxy => :environment do
    ec = Ezproxy::Client.new
    l = ec.links({})
    l.each do |link|
      HTTParty.get(link.uri.to_s)
    end
  end
end

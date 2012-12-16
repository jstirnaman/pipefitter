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
end

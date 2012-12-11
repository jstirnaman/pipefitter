# Rake tasks for Pipefitter

namespace :pipefitter do
  desc 'Compares import file titles to holdings in link resolver knowledgebase.'
  task :report_eresource_holdings => :environment do
    puts "\n\n== Comparing title holdings in file with eresource holdings."
    begin
      unless ARGV.empty?
        path = ARGV[1]
        p path.inspect
        table = CsvReporter::Import.new(path)
        table.each do |row|
          e = EResourceHolding.new(row[:title])
          row["local_holdings"] = e.kb_holdings.holdings?
        end
      CsvReporter.Export.new("eresource_holdings", table)
      else
      puts "### ERROR - No file supplied ###"
      end
    rescue RuntimeError
      puts "### ERROR - Comparing eresource holdings ###"
    end
  end
end

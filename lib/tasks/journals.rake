require 'csv'

namespace :csv do

  desc "Import CSV Data"
  task :import_stuff => :environment do

    csv_file_path = 'db/journaldata.csv'

    CSV.foreach(csv_file_path, encoding: 'windows-1251:utf-8', :col_sep => '|' ) do |row|
      Journal.create!({
        source_type: row[0],
        issn: row[1],
        name: row[2],
        publisher: row[3],
        peer_reviewed: row[4]      
      })
      puts "Row added!"
    end
  end
end
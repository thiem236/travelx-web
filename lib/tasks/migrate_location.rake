require 'rake'
namespace :migrate_location do
  task :migrate  => :environment do
    Attachment.find_each do |item|
      location = item.location
      if location
        item.place_type = location.type || 'unknown'
        item.place = location.name || 'unknown'
        item.place_id = location.item_id
        item.long = location.long
        item.lat = location.lat
        item.save
        puts "========================"
      end
    end
  end

  task :remove_location  => :environment do
    Attachment.find_each do |item|
      location = item.location
      if location
        item.location_id = nil
        item.save
        puts "========================"
      end
    end
  end
end
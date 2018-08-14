class LocationSerializer < ActiveModel::Serializer
  attributes :id, :name, :type, :rate, :lat, :long, :start_date, :end_date,:item_id

end
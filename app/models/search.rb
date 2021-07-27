class Search < ApplicationRecord
  scope :nearest, -> (lat, lon) {
    order(%{
      ST_DISTANCE(lonlat, 'POINT(%f %f)')
    } % [lon, lat])
  }

  scope :within, -> (lat, lon, distance) {
    where(%{
      ST_DISTANCE(lonlat, 'POINT(%f %f)') < %d
    } % [lon, lat, distance * 1609.34])
  }
end

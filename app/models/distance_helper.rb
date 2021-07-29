require 'geocoder'

module DistanceHelper

  def distance_between(lat1, lat2, lon1, long2)
    Geocoder::Calculations.distance_between([lat1, lon1], [lat2, long2])
  end

  def within_search_radius?(origin_lat, point_lat, origin_long, point_lon, origin_rad, point_rad)
    return false if point_rad > origin_rad # If the point radius is larger than the origin radius, return false
    point_distance = distance_between(origin_lat, point_lat, origin_long, point_lon)
    (point_distance + point_rad) < origin_rad
  end

end
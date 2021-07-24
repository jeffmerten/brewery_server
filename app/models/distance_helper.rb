require 'geocoder'

module DistanceHelper

  def distance_between(lat1, lat2, lon1, long2)
    Geocoder::Calculations.distance_between([lat1,lon1],[lat2,long2])
  end

end
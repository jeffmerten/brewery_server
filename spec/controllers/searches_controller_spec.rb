require 'rails_helper'
require 'active_support/json'

RSpec.describe SearchesController do

  # Errors

  it 'returns 400 when missing latitude for search' do
    get(:show, params: {longitude: -115.2752297, distance: 1})
    expect(response.code).to eql '400'
  end

  it 'returns 400 when when missing longitude for search' do
    get(:show, params: {latitude: 42.0190131, distance: 1})
    expect(response.code).to eql '400'
  end

  it 'returns 400 when missing distance for search' do
    get(:show, params: {latitude: 42.0190131, longitude: -115.2752297})
    expect(response.code).to eql '400'
  end

  it 'returns a 500 error when backing open API request fails' do
    response_error = Net::HTTPInternalServerError
    error = ::HTTParty::ResponseError.new(response_error)
    allow(::HTTParty).to receive(:get).with(anything).and_raise(error)
    get(:show, params: {latitude: 42.0190131, longitude: -115.2752297, distance: 1})
    expect(response.code).to eql '500'
  end

end

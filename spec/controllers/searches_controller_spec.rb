require 'rails_helper'
require 'active_support/json'

RSpec.describe SearchesController do

  def validate_json(expected_response_file_name, actual_response)
    file_path = 'spec/mock/output/' + expected_response_file_name + '.json'
    expected_response_json = JSON.parse(File.read(file_path))
    expect(JSON.parse(actual_response)).to eql expected_response_json
  end

  it 'returns a list of breweries within a search radius' do
    mock_response = JSON.parse(File.read('spec/mock/input/search_1.json'))
    allow(::HTTParty).to receive(:get).with(anything).and_return(mock_response)
    get(:show, params: {latitude: 38.9941, longitude: -105.0509, distance: 5})
    validate_json('search_1', response.body)
  end

  it 'returns no breweries within a search radius' do
    mock_response = JSON.parse(File.read('spec/mock/input/results_outside_range.json'))
    allow(::HTTParty).to receive(:get).with(anything).and_return(mock_response)
    get(:show, params: {latitude: 42.0190131, longitude: -115.2752297, distance: 1})
    expect(response.code).to eql '204'
  end

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
    expect { get(:show, params: {latitude: 42.0190131, longitude: -115.2752297, distance: 1}) }.to raise_error
  end

end

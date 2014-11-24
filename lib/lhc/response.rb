require 'typhoeus'

# The response contains the raw response (typhoeus)
# and provides functionality to access response data.
class LHC::Response

  attr_accessor :request

  # A response is initalized with the underlying raw response (typhoeus in our case)
  # and the associated request.
  def initialize(raw, request)
    self.request = request
    self.raw = raw
  end

  # Access response data.
  # Cache parsing.
  def data
    @data ||= JSON.parse(raw.body, object_class: OpenStruct)
    @data
  end

  def body
    raw.body
  end

  def code
    raw.code
  end

  def headers
    raw.headers
  end

  # Provides response time in ms.
  def time
    (raw.time || 0) * 1000
  end

  def timeout?
    raw.timed_out?
  end

  def success?
    raw.success?
  end

  private

  attr_accessor :raw

end

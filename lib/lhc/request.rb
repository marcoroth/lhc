require 'typhoeus'

class LHC::Request

  attr_accessor :response

  def initialize(options)
    request = create_request(options)
    LHC::Interceptor.intercept!(:before_request, request)
    request.run
    LHC::Interceptor.intercept!(:after_request, request)
    LHC::Interceptor.intercept!(:before_response, request)
    self
  end

  private

  def create_request(options)
    options = options.merge(options_from_config(options)) if LHC::Config[options[:url]]
    request = Typhoeus::Request.new(options.delete(:url), options)
    request.on_complete { |response| on_complete(response) }
    request
  end

  def options_from_config(options)
    url = options[:url]
    configuration = LHC::Config[url]
    options = options.deep_merge(configuration.options)
    options = compute_url_options!(options) if url.is_a?(Symbol)
    options
  end

  def compute_url_options!(options)
    configuration = LHC::Config[options[:url]] || fail("No endpoint found for #{options[:url]}")
    options = options.deep_merge(configuration.options)
    endpoint = LHC::Endpoint.new(configuration[:endpoint])
    options[:url] = endpoint.inject(options[:params])
    endpoint.remove_injected_params!(options[:params])
    options
  end

  def on_complete(response)
    self.response = LHC::Response.new(response)
    LHC::Interceptor.intercept!(:after_response, self.response)
    if response.code.to_s[/^(2\d\d+)/]
      on_success(response)
    else
      on_error(response)
    end
  end

  def on_success(response)
  end

  def on_error(response)
    error = LHC::Error.find(response.code)
    fail error.new("#{response.code} #{response.body}", response)
  end
end

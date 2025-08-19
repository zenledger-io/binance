require 'faraday'

require_relative 'rest/sign_request_middleware'
require_relative 'rest/timestamp_request_middleware'
require_relative 'rest/clients'
require_relative 'rest/endpoints'
require_relative 'rest/methods'

module Binance
  module Client
    class REST
      BASE_URL = ''
      US_BASED = 'https://api.binance.us'
      NON_US_BASED = 'https://api.binance.com'

      def initialize(api_key: '', secret_key: '', type: 'non_us_based', adapter: Faraday.default_adapter)
        url = (type == 'us_based') ? US_BASED : NON_US_BASED
        BASE_URL.replace url
        @clients = {}
        @clients[:public]   = public_client adapter
        @clients[:verified] = verified_client api_key, adapter
        @clients[:signed]   = signed_client api_key, secret_key, adapter
        @clients[:withdraw] = withdraw_client api_key, secret_key, adapter
        @clients[:public_withdraw] = public_withdraw_client adapter
        @clients[:dividend] = dividend_client api_key, secret_key, adapter        
      end

      METHODS.each do |method|
        define_method(method[:name]) do |options = {}|
          response = @clients.fetch(method[:client]).public_send(method[:action]) do |req|
            req.url ENDPOINTS.fetch(method[:endpoint])

            # camelCase params for SAPI (beginTime, endTime, transactionType, etc.)
            params = options.map { |k, v| [camelize(k.to_s), v] }.to_h

            # ensure ms for common time keys if caller passed seconds
            %w[beginTime endTime startTime finishTime timestamp].each do |k|
              params[k] = ensure_ms(params[k]) if params[k]
            end

            # generous recvWindow for signed requests (helps with slight clock skew)
            params['recvWindow'] ||= 10_000 if method[:client] == :signed

            req.params.merge!(params)
          end

          body = response.body.to_s

          # Only normalize fiat endpoints (opt-in via METHODS entry)
          if method[:normalize] == :fiat_list
            return normalize_fiat_list(body)
          end

          # Default: keep original gem behavior (return raw String)
          body
        end
      end

      def self.add_query_param(query, key, value)
        query = query.to_s
        query = query.dup if query.frozen?
        query << '&' unless query.empty?
        query << "#{Faraday::Utils.escape key}=#{Faraday::Utils.escape value}"
      end

      private

      def camelize(str)
        str.split('_').map.with_index { |word, i| i.zero? ? word : word.capitalize }.join
      end

      def ensure_ms(val)
        i = val.to_i
        i < 1_000_000_000_000 ? i * 1000 : i
      end

      # For fiat endpoints only: parse JSON and extract the list safely
      # Accepts: {"code":"000000","message":"success","data":[...], ...}
      # Falls back cleanly on unexpected shapes.
      def normalize_fiat_list(raw)
        s = raw.to_s.strip
        return [] if s.empty? || s == 'null'
        parsed = JSON.parse(s) rescue nil
        case parsed
        when Array
          parsed
        when Hash
          parsed['data'] || parsed['rows'] || parsed['list'] || []
        else
          []
        end
      end
    end
  end
end
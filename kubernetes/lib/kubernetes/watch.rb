# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'json'
require 'uri'

# The Kubernetes module encapsulates the Kubernetes client for Ruby
module Kubernetes
  # The Watch class provides the ability to watch a specific resource for
  # updates.
  class Watch
    MAX_RECONNECT_ATTEMPTS = 3
    RECONNECT_BACKOFF_SECONDS = 1.0

    def initialize(client)
      @client = client
    end

    def make_url(path, resource_version)
      uri = URI.parse(path)
      query = URI.decode_www_form(uri.query || '').to_h
      query['watch'] = 'true'
      query['resourceVersion'] = resource_version if resource_version
      query_string = query.map { |k, v| "#{URI.encode_www_form_component(k).gsub('+', '%20')}=#{URI.encode_www_form_component(v).gsub('+', '%20')}" }.join('&')
      "#{uri.path}?#{query_string}"
    end

    def connect(path, resource_version = nil, &_block)
      current_resource_version = resource_version
      reconnect_attempts = 0

      loop do
        reconnect_requested = false
        opts = { auth_names: ['BearerToken'] }
        url = make_url(path, current_resource_version)
        request = @client.build_request('GET', url, opts)
        last = ''

        process_event = lambda do |part|
          return if part.nil? || part.strip.empty?

          event = parse_event(part)
          return unless event

          if watch_reset_event?(event)
            current_resource_version = nil
            reconnect_requested = true
            next
          end

          current_resource_version = extract_resource_version(event) || current_resource_version
          yield event
        end

        request.on_body do |chunk|
          last, pieces = split_lines(last, chunk)
          pieces.each { |part| process_event.call(part) }
        end

        request.on_complete do |_response|
          process_event.call(last)
          last = ''
        end

        response = request.run
        reconnect_reason = reconnect_reason(response, reconnect_requested)
        return response unless reconnect_reason
        raise_terminal_watch_error(response, reconnect_reason) if reconnect_attempts >= MAX_RECONNECT_ATTEMPTS

        reconnect_attempts += 1
        sleep reconnect_backoff_seconds(reconnect_attempts - 1) if reconnect_reason == :transport
      end
    end

    def split_lines(last, chunk)
      data = chunk
      data = last + '' + data

      ix = data.rindex("\n")
      return [data, []] unless ix

      complete = data[0..ix]
      last = data[(ix + 1)..data.length]
      [last, complete.split(/\n/)]
    end

    private

    def parse_event(part)
      JSON.parse(part)
    rescue JSON::ParserError => e
      warn "Failed to parse watch event: #{e.message}. Raw event: #{part.inspect}"
      nil
    end

    def extract_resource_version(event)
      object = event['object']
      return nil unless object.is_a?(Hash)

      metadata = object['metadata']
      return metadata['resourceVersion'] if metadata.is_a?(Hash)

      object['resourceVersion']
    end

    def watch_reset_event?(event)
      event['type'] == 'ERROR' && event.dig('object', 'code').to_i == 410
    end

    def reconnect_reason(response, reconnect_requested)
      return :reset if reconnect_requested
      return nil unless response

      return :transport if response.timed_out? || response.code.to_i.zero?

      nil
    end

    def reconnect_backoff_seconds(reconnect_attempt)
      RECONNECT_BACKOFF_SECONDS * (2**reconnect_attempt)
    end

    def raise_terminal_watch_error(response, reconnect_reason)
      if reconnect_reason == :reset
        raise ApiError.new(code: 410, message: 'Watch resource version expired')
      elsif response&.timed_out?
        raise ApiError.new('Watch connection timed out')
      elsif response && response.code.to_i.zero?
        raise ApiError.new(code: 0, message: response.return_message)
      end
    end
  end
end

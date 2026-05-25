# Copyright 2017 The Kubernetes Authors.
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

require 'spec_helper'

describe Kubernetes::ApiError do
  describe 'inheritance' do
    it 'inherits from StandardError' do
      expect(described_class.ancestors).to include(StandardError)
    end
  end

  describe '.initialize' do
    context 'with no argument' do
      it 'creates an error with nil message' do
        error = described_class.new
        expect(error.message).to eq('Error message: the server returns an error')
      end
    end

    context 'with a string argument' do
      it 'sets the message' do
        error = described_class.new('Something went wrong')
        expect(error.message).to eq('Something went wrong')
      end
    end

    context 'with a hash argument including :message' do
      it 'sets the message from :message key' do
        error = described_class.new(:code => 404, :message => 'Not Found')
        expect(error.message).to include('Not Found')
        expect(error.code).to eq(404)
      end

      it 'sets instance variables from the hash' do
        error = described_class.new(
          :code => 500,
          :message => 'Internal Server Error',
          :response_headers => {'content-type' => 'application/json'},
          :response_body => '{"error": "server error"}'
        )
        expect(error.code).to eq(500)
        expect(error.message).to include('Internal Server Error')
        expect(error.response_headers).to eq({'content-type' => 'application/json'})
        expect(error.response_body).to eq('{"error": "server error"}')
      end

      it 'handles string key "message"' do
        error = described_class.new('message' => 'Error via string key')
        expect(error.message).to include('Error via string key')
      end
    end

    context 'with an empty hash' do
      it 'defaults to the fallback message' do
        error = described_class.new({})
        expect(error.message).to eq('Error message: the server returns an error')
      end
    end

    context 'with a hash argument without :message' do
      it 'sets instance variables from the hash' do
        error = described_class.new(:code => 403, :response_body => 'Forbidden')
        expect(error.code).to eq(403)
        expect(error.response_body).to eq('Forbidden')
      end
    end

    context 'with nil argument' do
      it 'defaults to the fallback message' do
        error = described_class.new(nil)
        expect(error.message).to eq('Error message: the server returns an error')
      end
    end

    context 'with a non-string, non-hash argument' do
      it 'handles numeric arguments' do
        error = described_class.new(42)
        expect(error.message).to eq(42)
      end
    end
  end

  describe 'unset attributes' do
    it 'returns nil for code, response_headers, and response_body when not set' do
      error = described_class.new('Some error')
      expect(error.code).to be_nil
      expect(error.response_headers).to be_nil
      expect(error.response_body).to be_nil
    end
  end

  describe '#message' do
    it 'returns the default message when @message is nil' do
      error = described_class.new
      expect(error.message).to eq('Error message: the server returns an error')
    end

    it 'includes HTTP status code when code is set' do
      error = described_class.new(:code => 404, :message => 'Not Found')
      expect(error.message).to include('HTTP status code: 404')
    end

    it 'includes response headers when set' do
      headers = {'x-request-id' => 'abc123'}
      error = described_class.new(:message => 'Error', :response_headers => headers)
      expect(error.message).to include('Response headers: ')
      expect(error.message).to include('x-request-id')
    end

    it 'includes response body when set' do
      body = '{"message": "not found"}'
      error = described_class.new(:message => 'Error', :response_body => body)
      expect(error.message).to include('Response body: ')
      expect(error.message).to include('not found')
    end

    it 'includes all information when all attributes are set' do
      error = described_class.new(
        :code => 500,
        :message => 'Server Error',
        :response_headers => {'content-type' => 'application/json'},
        :response_body => '{"error": "internal"}'
      )
      msg = error.message
      expect(msg).to include('Server Error')
      expect(msg).to include('HTTP status code: 500')
      expect(msg).to include('Response headers: ')
      expect(msg).to include('Response body: ')
    end
  end

  describe '#to_s' do
    it 'returns the same output as #message' do
      error = described_class.new(:code => 400, :message => 'Bad Request')
      expect(error.to_s).to eq(error.message)
    end

    it 'returns the default message when no message is set' do
      error = described_class.new
      expect(error.to_s).to eq('Error message: the server returns an error')
    end
  end
end

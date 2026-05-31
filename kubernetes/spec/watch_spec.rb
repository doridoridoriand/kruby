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

require 'spec_helper'
require 'kubernetes/watch'

describe 'WatchClient' do
  it 'should construct correctly' do
    Kubernetes::Watch.new(nil)
  end

  it 'should connect correctly with resource version' do
    config = Kubernetes::Configuration.new
    config.scheme = 'http'
    config.host = 'k8s.io:8080'
    client = Kubernetes::ApiClient.new(config)
    user_agent = client.default_headers['User-Agent']
    url = 'http://k8s.io:8080/some/path?watch=true&resourceVersion=foo'

    WebMock.stub_request(:get, url)
           .with(
             headers: {
               'Authorization' => '',
               'Content-Type' => 'application/json',
               'Expect' => '',
               'User-Agent' => user_agent
             }
           )
           .to_return(status: 200, body: "{}\n", headers: {})

    watch = Kubernetes::Watch.new(client)
    result = []
    watch.connect('/some/path', 'foo') do |obj|
      result << obj
    end
  end

  it 'should connect correctly' do
    config = Kubernetes::Configuration.new
    config.scheme = 'http'
    config.host = 'k8s.io:8080'
    client = Kubernetes::ApiClient.new(config)
    user_agent = client.default_headers['User-Agent']
    body = "{ \"foo\": \"bar\" }\n{ \"baz\": \"blah\" }\n{}\n"

    WebMock.stub_request(:get, 'http://k8s.io:8080/some/path?watch=true')
           .with(
             headers: {
               'Authorization' => '',
               'Content-Type' => 'application/json',
               'Expect' => '',
               'User-Agent' => user_agent
             }
           )
           .to_return(status: 200, body: body, headers: {})

    watch = Kubernetes::Watch.new(client)
    result = []
    watch.connect('/some/path', nil) do |obj|
      result << obj
    end

    expect(result.length).to eq(3)
    expect(result[0]['foo']).to eq('bar')
    expect(result[1]['baz']).to eq('blah')
  end

  it 'should skip malformed watch events and continue streaming' do
    config = Kubernetes::Configuration.new
    config.scheme = 'http'
    config.host = 'k8s.io:8080'
    client = Kubernetes::ApiClient.new(config)
    user_agent = client.default_headers['User-Agent']
    body = "{ \"foo\": \"bar\" }\nnot-json\n{ \"baz\": \"blah\" }\n"

    WebMock.stub_request(:get, 'http://k8s.io:8080/some/path?watch=true')
           .with(
             headers: {
               'Authorization' => '',
               'Content-Type' => 'application/json',
               'Expect' => '',
               'User-Agent' => user_agent
             }
           )
           .to_return(status: 200, body: body, headers: {})

    watch = Kubernetes::Watch.new(client)
    result = []

    expect do
      watch.connect('/some/path', nil) do |obj|
        result << obj
      end
    end.to output(/Failed to parse watch event: .*Raw event: "not-json"/m).to_stderr

    expect(result.length).to eq(2)
    expect(result[0]['foo']).to eq('bar')
    expect(result[1]['baz']).to eq('blah')
  end

  it 'should propagate JSON parser errors raised by the callback' do
    config = Kubernetes::Configuration.new
    config.scheme = 'http'
    config.host = 'k8s.io:8080'
    client = Kubernetes::ApiClient.new(config)
    user_agent = client.default_headers['User-Agent']
    body = "{ \"foo\": \"bar\" }\n{ \"payload\": \"not-json\" }\n"

    WebMock.stub_request(:get, 'http://k8s.io:8080/some/path?watch=true')
           .with(
             headers: {
               'Authorization' => '',
               'Content-Type' => 'application/json',
               'Expect' => '',
               'User-Agent' => user_agent
             }
           )
           .to_return(status: 200, body: body, headers: {})

    watch = Kubernetes::Watch.new(client)
    result = []

    expect do
      watch.connect('/some/path', nil) do |obj|
        result << obj['foo'] if obj['foo']
        JSON.parse(obj['payload']) if obj['payload']
      end
    end.to raise_error(JSON::ParserError)

    expect(result).to eq(['bar'])
  end

  it 'should parse chunks correctly' do
    client = Kubernetes::Watch.new(nil)
    last = ''

    last, data = client.split_lines(last, "foo\nbar\nba")

    expect(last).to eq('ba')
    expect(data).to eq(%w[foo bar])

    last, data = client.split_lines(last, "z\nblah\n")
    expect(last).to eq('')
    expect(data).to eq(%w[baz blah])
  end

  describe '#make_url' do
    let(:watch) { Kubernetes::Watch.new(nil) }

    it 'should construct URL with watch=true' do
      expect(watch.make_url('/some/path', nil)).to match(/\?watch=true/)
    end

    it 'should construct URL with watch=true and resourceVersion' do
      url = watch.make_url('/some/path', '123')
      expect(url).to match(/watch=true/)
      expect(url).to match(/resourceVersion=123/)
    end

    it 'should handle path with existing query parameters' do
      url = watch.make_url('/api/v1/pods?labelSelector=app%3Dweb', '456')
      expect(url).to match(/watch=true/)
      expect(url).to match(/resourceVersion=456/)
      expect(url).to match(/labelSelector=app%3Dweb/)
    end

    it 'should URL encode resourceVersion' do
      url = watch.make_url('/api/v1/pods', 'rv with spaces')
      expect(url).to match(/resourceVersion=rv%20with%20spaces/)
    end

    it 'should preserve existing query parameters while adding watch' do
      url = watch.make_url('/api/v1/pods?fieldSelector=status%3DRunning', nil)
      expect(url).to match(/watch=true/)
      expect(url).to match(/fieldSelector=status%3DRunning/)
    end
  end
end

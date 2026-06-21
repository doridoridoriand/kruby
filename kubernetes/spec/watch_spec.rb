# frozen_string_literal: true

require "spec_helper"
require "kubernetes/watch"
require "timeout"
require "webmock/rspec"

RSpec.describe Kubernetes::Watch do
  let(:config) do
    Kubernetes::Configuration.new.tap do |c|
      c.scheme = "http"
      c.host = "k8s.example.com:8080"
    end
  end
  let(:client) { Kubernetes::ApiClient.new(config) }
  let(:user_agent) { client.default_headers["User-Agent"] }
  let(:watch) { Kubernetes::Watch.new(client) }

  it "should construct correctly" do
    Kubernetes::Watch.new(nil)
  end

  it "should connect correctly with resource version" do
    url = "http://k8s.example.com:8080/some/path?watch=true&resourceVersion=foo"

    WebMock.stub_request(:get, url)
           .with(
             headers: {
               "Authorization" => "",
               "Content-Type" => "application/json",
               "Expect" => "",
               "User-Agent" => user_agent
             }
           )
           .to_return(status: 200, body: "{}\n", headers: {})

    watch = Kubernetes::Watch.new(client)
    result = []
    watch.connect("/some/path", "foo") do |obj|
      result << obj
    end
  end

  it "should connect correctly" do
    body = "{ \"foo\": \"bar\" }\n{ \"baz\": \"blah\" }\n{}\n"

    WebMock.stub_request(:get, "http://k8s.example.com:8080/some/path?watch=true")
           .with(
             headers: {
               "Authorization" => "",
               "Content-Type" => "application/json",
               "Expect" => "",
               "User-Agent" => user_agent
             }
           )
           .to_return(status: 200, body: body, headers: {})

    watch = Kubernetes::Watch.new(client)
    result = []
    watch.connect("/some/path", nil) do |obj|
      result << obj
    end

    expect(result.length).to eq(3)
    expect(result[0]["foo"]).to eq("bar")
    expect(result[1]["baz"]).to eq("blah")
  end

  it "should skip malformed watch events and continue streaming" do
    body = "{ \"foo\": \"bar\" }\nnot-json\n{ \"baz\": \"blah\" }\n"

    WebMock.stub_request(:get, "http://k8s.example.com:8080/some/path?watch=true")
           .with(
             headers: {
               "Authorization" => "",
               "Content-Type" => "application/json",
               "Expect" => "",
               "User-Agent" => user_agent
             }
           )
           .to_return(status: 200, body: body, headers: {})

    watch = Kubernetes::Watch.new(client)
    result = []

    expect do
      watch.connect("/some/path", nil) do |obj|
        result << obj
      end
    end.to output(/Failed to parse watch event: .*Raw event: "not-json"/m).to_stderr

    expect(result.length).to eq(2)
    expect(result[0]["foo"]).to eq("bar")
    expect(result[1]["baz"]).to eq("blah")
  end

  it "should propagate JSON parser errors raised by the callback" do
    body = "{ \"foo\": \"bar\" }\n{ \"payload\": \"not-json\" }\n"

    WebMock.stub_request(:get, "http://k8s.example.com:8080/some/path?watch=true")
           .with(
             headers: {
               "Authorization" => "",
               "Content-Type" => "application/json",
               "Expect" => "",
               "User-Agent" => user_agent
             }
           )
           .to_return(status: 200, body: body, headers: {})

    watch = Kubernetes::Watch.new(client)
    result = []

    expect do
      watch.connect("/some/path", nil) do |obj|
        result << obj["foo"] if obj["foo"]
        JSON.parse(obj["payload"]) if obj["payload"]
      end
    end.to raise_error(JSON::ParserError)

    expect(result).to eq(["bar"])
  end

  it "should parse chunks correctly" do
    client_obj = Kubernetes::Watch.new(nil)
    last = ""

    last, data = client_obj.split_lines(last, "foo\nbar\nba")

    expect(last).to eq("ba")
    expect(data).to eq(%w[foo bar])

    last, data = client_obj.split_lines(last, "z\nblah\n")
    expect(last).to eq("")
    expect(data).to eq(%w[baz blah])
  end

  describe "#make_url" do
    let(:watch) { Kubernetes::Watch.new(nil) }

    it "should construct URL with watch=true" do
      expect(watch.make_url("/some/path", nil)).to match(/\?watch=true/)
    end

    it "should construct URL with watch=true and resourceVersion" do
      url = watch.make_url("/some/path", "123")
      expect(url).to match(/watch=true/)
      expect(url).to match(/resourceVersion=123/)
    end

    it "should handle path with existing query parameters" do
      url = watch.make_url("/api/v1/pods?labelSelector=app%3Dweb", "456")
      expect(url).to match(/watch=true/)
      expect(url).to match(/resourceVersion=456/)
      expect(url).to match(/labelSelector=app%3Dweb/)
    end

    it "should URL encode resourceVersion" do
      url = watch.make_url("/api/v1/pods", "rv with spaces")
      expect(url).to match(/resourceVersion=rv%20with%20spaces/)
    end

    it "should preserve existing query parameters while adding watch" do
      url = watch.make_url("/api/v1/pods?fieldSelector=status%3DRunning", nil)
      expect(url).to match(/watch=true/)
      expect(url).to match(/fieldSelector=status%3DRunning/)
    end

    it "should handle empty path" do
      url = watch.make_url("", nil)
      expect(url).to eq("?watch=true")
    end

    it "should handle path with multiple existing query parameters" do
      url = watch.make_url("/api/v1/namespaces/default/pods?labelSelector=app%3Dweb&fieldSelector=status%3DRunning", "999")
      expect(url).to match(/watch=true/)
      expect(url).to match(/resourceVersion=999/)
      expect(url).to match(/labelSelector=app%3Dweb/)
      expect(url).to match(/fieldSelector=status%3DRunning/)
    end
  end

  describe "#split_lines" do
    let(:watch) { Kubernetes::Watch.new(nil) }

    it "handles single complete line" do
      last, data = watch.split_lines("", "line1\n")
      expect(last).to eq("")
      expect(data).to eq(["line1"])
    end

    it "handles incomplete line at the end" do
      last, data = watch.split_lines("", "line1\nline2")
      expect(last).to eq("line2")
      expect(data).to eq(["line1"])
    end

    it "handles empty chunk" do
      last, data = watch.split_lines("", "")
      expect(last).to eq("")
      expect(data).to eq([])
    end

    it "handles remaining buffer from previous chunk" do
      last, data = watch.split_lines("partial", "line\n")
      expect(last).to eq("")
      expect(data).to eq(["partialline"])
    end

    it "handles remaining buffer with incomplete new chunk" do
      last, data = watch.split_lines("buf", "line\nnew")
      expect(last).to eq("new")
      expect(data).to eq(["bufline"])
    end

    it "handles multiple lines in one chunk" do
      last, data = watch.split_lines("", "a\nb\nc\n")
      expect(last).to eq("")
      expect(data).to eq(%w[a b c])
    end

    it "handles no trailing newline with buffer" do
      last, data = watch.split_lines("", "a\nb")
      expect(last).to eq("b")
      expect(data).to eq(["a"])
    end

    it "handles binary data with newlines" do
      last, data = watch.split_lines("", "\x00\x01\n\x02\x03\n")
      expect(last).to eq("")
      expect(data).to eq(["\x00\x01", "\x02\x03"])
    end
  end

  describe "#connect — watch event types" do
    it "receives ADDED, MODIFIED, DELETED events" do
      body = '{"type":"ADDED","object":{"kind":"Pod","metadata":{"name":"nginx"}}}' \
             "\n{\"type\":\"MODIFIED\",\"object\":{\"kind\":\"Pod\",\"metadata\":{\"name\":\"nginx\",\"status\":\"Running\"}}}" \
             "\n{\"type\":\"DELETED\",\"object\":{\"kind\":\"Pod\",\"metadata\":{\"name\":\"nginx\"}}}\n"

      WebMock.stub_request(:get, "http://k8s.example.com:8080/api/v1/pods?watch=true")
             .with(headers: { "Content-Type" => "application/json", "Expect" => "" })
             .to_return(status: 200, body: body, headers: {})

      result = []
      watch.connect("/api/v1/pods", nil) { |obj| result << obj }

      expect(result.length).to eq(3)
      expect(result[0]["type"]).to eq("ADDED")
      expect(result[1]["type"]).to eq("MODIFIED")
      expect(result[2]["type"]).to eq("DELETED")
    end

    it "receives ERROR events" do
      body = "{\"type\":\"ERROR\",\"object\":{\"kind\":\"Status\",\"message\":\"too old resource version\"}}\n"

      WebMock.stub_request(:get, "http://k8s.example.com:8080/api/v1/pods?watch=true")
             .with(headers: { "Content-Type" => "application/json", "Expect" => "" })
             .to_return(status: 200, body: body, headers: {})

      result = []
      watch.connect("/api/v1/pods", nil) { |obj| result << obj }

      expect(result.length).to eq(1)
      expect(result[0]["type"]).to eq("ERROR")
    end
  end

  describe "#connect — edge cases" do
    it "handles empty events (curly braces only)" do
      body = "{}\n{ \"foo\": \"bar\" }\n"

      WebMock.stub_request(:get, "http://k8s.example.com:8080/api/v1/pods?watch=true")
             .with(headers: { "Content-Type" => "application/json", "Expect" => "" })
             .to_return(status: 200, body: body, headers: {})

      result = []
      watch.connect("/api/v1/pods", nil) { |obj| result << obj }

      expect(result.length).to eq(2)
      expect(result[0]).to eq({})
      expect(result[1]["foo"]).to eq("bar")
    end

    it "handles multiple malformed events in a row" do
      body = "not-json\ngarbage\n{ \"valid\": true }\n"

      WebMock.stub_request(:get, "http://k8s.example.com:8080/api/v1/pods?watch=true")
             .with(headers: { "Content-Type" => "application/json", "Expect" => "" })
             .to_return(status: 200, body: body, headers: {})

      result = []
      expect do
        watch.connect("/api/v1/pods", nil) { |obj| result << obj }
      end.to output(/Failed to parse watch event/).to_stderr

      expect(result.length).to eq(1)
      expect(result[0]["valid"]).to eq(true)
    end

    it "handles large watch payloads" do
      objects = (1..50).map { |i|
        "{ \"type\": \"ADDED\", \"object\": { \"kind\": \"Pod\", \"metadata\": { \"name\": \"pod-#{i}\" } } }"
      }.join("\n") + "\n"

      WebMock.stub_request(:get, "http://k8s.example.com:8080/api/v1/pods?watch=true")
             .with(headers: { "Content-Type" => "application/json", "Expect" => "" })
             .to_return(status: 200, body: objects, headers: {})

      result = []
      watch.connect("/api/v1/pods", nil) { |obj| result << obj }

      expect(result.length).to eq(50)
      expect(result[0]["object"]["metadata"]["name"]).to eq("pod-1")
      expect(result[49]["object"]["metadata"]["name"]).to eq("pod-50")
    end

    it "keeps concurrent watch connections isolated on the same Watch instance" do
      WebMock.stub_request(:get, "http://k8s.example.com:8080/api/v1/pods?watch=true&resourceVersion=rv-1")
             .with(headers: { "Content-Type" => "application/json", "Expect" => "" })
             .to_return(status: 200, body: "{\"type\":\"ADDED\",\"object\":{\"metadata\":{\"name\":\"pod-1\"}}}\n", headers: {})
      WebMock.stub_request(:get, "http://k8s.example.com:8080/api/v1/services?watch=true&resourceVersion=rv-2")
             .with(headers: { "Content-Type" => "application/json", "Expect" => "" })
             .to_return(status: 200, body: "{\"type\":\"ADDED\",\"object\":{\"metadata\":{\"name\":\"svc-1\"}}}\n", headers: {})

      results = Queue.new
      threads = [
        Thread.new { watch.connect("/api/v1/pods", "rv-1") { |obj| results << [:pods, obj] } },
        Thread.new { watch.connect("/api/v1/services", "rv-2") { |obj| results << [:services, obj] } }
      ]
      begin
        Timeout.timeout(5) do
          threads.each(&:value)
        end
      ensure
        threads.each do |thread|
          next unless thread.alive?

          thread.kill
          thread.join
        end
      end

      observed = 2.times.map { results.pop(true) }
      expect(observed).to contain_exactly(
        [:pods, { "type" => "ADDED", "object" => { "metadata" => { "name" => "pod-1" } } }],
        [:services, { "type" => "ADDED", "object" => { "metadata" => { "name" => "svc-1" } } }]
      )
    end
  end
end

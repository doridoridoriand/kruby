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

describe Kubernetes::ConfigError do
  it 'inherits from RuntimeError' do
    expect(described_class.ancestors).to include(RuntimeError)
  end

  it 'can be raised and caught' do
    expect {
      raise Kubernetes::ConfigError
    }.to raise_error(Kubernetes::ConfigError)
  end

  it 'preserves the message' do
    message = 'Configuration failed'
    begin
      raise Kubernetes::ConfigError, message
    rescue Kubernetes::ConfigError => e
      expect(e.message).to eq(message)
    end
  end
end

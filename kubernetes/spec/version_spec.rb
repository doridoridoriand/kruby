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

describe Kubernetes::VERSION do
  it 'is a String' do
    expect(Kubernetes::VERSION).to be_a(String)
  end

  it 'matches semantic versioning format (X.Y.Z.W)' do
    expect(Kubernetes::VERSION).to match(/\A\d+\.\d+\.\d+\.\d+\z/)
  end

  it 'matches the version declared in kubernetes.gemspec' do
    gemspec = Gem::Specification.load(File.expand_path('../kubernetes.gemspec', __dir__))
    expect(Kubernetes::VERSION).to eq(gemspec.version.to_s)
  end
end

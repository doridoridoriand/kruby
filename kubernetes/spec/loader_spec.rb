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

describe Kubernetes::Configuration do
  describe '.default_config' do
    let(:original_kubeconfig) { ENV['KUBECONFIG'] }
    let(:original_home) { ENV['HOME'] }

    around do |example|
      # Save and clear env vars that affect config loading
      ENV.delete('KUBECONFIG')
      ENV.delete('HOME')
      example.run
    ensure
      # Restore env vars
      if original_kubeconfig.nil?
        ENV.delete('KUBECONFIG')
      else
        ENV['KUBECONFIG'] = original_kubeconfig
      end
      if original_home.nil?
        ENV.delete('HOME')
      else
        ENV['HOME'] = original_home
      end
    end

    context 'when KUBECONFIG env variable points to an existing file' do
      let(:kubeconfig_path) { '/tmp/test-kubeconfig' }

      it 'loads the file specified by KUBECONFIG' do
        ENV['KUBECONFIG'] = kubeconfig_path
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(kubeconfig_path).and_return(true)
        kube_config = instance_double(Kubernetes::KubeConfig)
        allow(Kubernetes::KubeConfig).to receive(:new).with(kubeconfig_path).and_return(kube_config)
        allow(kube_config).to receive(:configure)

        result = described_class.default_config
        expect(result).to be_a(Kubernetes::Configuration)
        expect(kube_config).to have_received(:configure).with(result)
      end
    end

    context 'when KUBECONFIG is set but file does not exist' do
      it 'falls through to default home location or fallback' do
        ENV['KUBECONFIG'] = '/nonexistent/kubeconfig'
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/nonexistent/kubeconfig').and_return(false)
        ENV['HOME'] = '/tmp/test-home'
        default_path = '/tmp/test-home/.kube/config'
        allow(File).to receive(:exist?).with(default_path).and_return(false)
        allow(Kubernetes::InClusterConfig).to receive(:in_cluster?).and_return(false)

        result = described_class.default_config
        expect(result).to be_a(Kubernetes::Configuration)
        expect(result.scheme).to eq('http')
        expect(result.host).to eq('localhost:8080')
      end
    end

    context 'when KUBECONFIG is not set and ~/.kube/config exists' do
      let(:default_kubeconfig) { '/home/user/.kube/config' }

      it 'loads the default kubeconfig file' do
        ENV['HOME'] = '/home/user'
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(default_kubeconfig).and_return(true)
        kube_config = instance_double(Kubernetes::KubeConfig)
        allow(Kubernetes::KubeConfig).to receive(:new).with(default_kubeconfig).and_return(kube_config)
        allow(kube_config).to receive(:configure)

        result = described_class.default_config
        expect(result).to be_a(Kubernetes::Configuration)
        expect(kube_config).to have_received(:configure).with(result)
      end
    end

    context 'when no local config and running in cluster' do
      it 'uses InClusterConfig' do
        ENV['HOME'] = '/tmp/test-home'
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/tmp/test-home/.kube/config').and_return(false)
        allow(Kubernetes::InClusterConfig).to receive(:in_cluster?).and_return(true)
        in_cluster_config = instance_double(Kubernetes::InClusterConfig)
        allow(Kubernetes::InClusterConfig).to receive(:new).and_return(in_cluster_config)
        allow(in_cluster_config).to receive(:configure)

        result = described_class.default_config
        expect(result).to be_a(Kubernetes::Configuration)
        expect(in_cluster_config).to have_received(:configure).with(result)
      end
    end

    context 'when no local config and not in cluster' do
      it 'falls back to localhost:8080' do
        ENV['HOME'] = '/tmp/test-home'
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/tmp/test-home/.kube/config').and_return(false)
        allow(Kubernetes::InClusterConfig).to receive(:in_cluster?).and_return(false)

        result = described_class.default_config
        expect(result).to be_a(Kubernetes::Configuration)
        expect(result.scheme).to eq('http')
        expect(result.host).to eq('localhost:8080')
      end
    end
  end

  describe '.load_local_config' do
    let(:result) { Kubernetes::Configuration.new }
    let(:original_kubeconfig) { ENV['KUBECONFIG'] }
    let(:original_home) { ENV['HOME'] }

    around do |example|
      ENV.delete('KUBECONFIG')
      ENV.delete('HOME')
      example.run
    ensure
      if original_kubeconfig.nil?
        ENV.delete('KUBECONFIG')
      else
        ENV['KUBECONFIG'] = original_kubeconfig
      end
      if original_home.nil?
        ENV.delete('HOME')
      else
        ENV['HOME'] = original_home
      end
    end

    context 'when KUBECONFIG points to an existing file' do
      it 'loads the KUBECONFIG file' do
        ENV['KUBECONFIG'] = '/custom/kubeconfig'
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/custom/kubeconfig').and_return(true)
        kube_config = instance_double(Kubernetes::KubeConfig)
        allow(Kubernetes::KubeConfig).to receive(:new).with('/custom/kubeconfig').and_return(kube_config)
        allow(kube_config).to receive(:configure).and_return(result)

        output = described_class.load_local_config(result)
        expect(output).to eq(result)
        expect(kube_config).to have_received(:configure).with(result)
      end
    end

    context 'when KUBECONFIG does not exist and ~/.kube/config does not exist' do
      it 'returns nil' do
        ENV['KUBECONFIG'] = '/nonexistent'
        ENV['HOME'] = '/tmp/test-home'
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/nonexistent').and_return(false)
        allow(File).to receive(:exist?).with('/tmp/test-home/.kube/config').and_return(false)

        output = described_class.load_local_config(result)
        expect(output).to be_nil
      end
    end

    context 'when KUBECONFIG is not set and ~/.kube/config does not exist' do
      it 'returns nil' do
        ENV['HOME'] = '/tmp/test-home'
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/tmp/test-home/.kube/config').and_return(false)

        output = described_class.load_local_config(result)
        expect(output).to be_nil
      end
    end

    context 'when KUBECONFIG does not exist but ~/.kube/config exists' do
      it 'loads the default kubeconfig' do
        ENV['KUBECONFIG'] = '/nonexistent'
        ENV['HOME'] = '/home/user'
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/nonexistent').and_return(false)
        allow(File).to receive(:exist?).with('/home/user/.kube/config').and_return(true)
        kube_config = instance_double(Kubernetes::KubeConfig)
        allow(Kubernetes::KubeConfig).to receive(:new).with('/home/user/.kube/config').and_return(kube_config)
        allow(kube_config).to receive(:configure).and_return(result)

        output = described_class.load_local_config(result)
        expect(output).to eq(result)
      end
    end
  end

  describe '.load_file_config' do
    let(:result) { Kubernetes::Configuration.new }

    it 'creates a KubeConfig from the file and configures the result' do
      file_path = '/some/kubeconfig'
      kube_config = instance_double(Kubernetes::KubeConfig)
      allow(Kubernetes::KubeConfig).to receive(:new).with(file_path).and_return(kube_config)
      allow(kube_config).to receive(:configure).with(result).and_return(result)

      output = described_class.load_file_config(file_path, result)

      expect(output).to eq(result)
      expect(Kubernetes::KubeConfig).to have_received(:new).with(file_path)
      expect(kube_config).to have_received(:configure).with(result)
    end
  end
end

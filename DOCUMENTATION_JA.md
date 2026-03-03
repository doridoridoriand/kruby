# Kruby Client ドキュメント

## プロジェクト概要

このプロジェクトは、Kubernetes APIと通信するための公式Rubyクライアントライブラリです。OpenAPI Generatorを使用してKubernetes APIの仕様から自動生成されており、Kubernetesクラスタとの対話を簡単に行うことができます。

### 現在のステータス

- **バージョン**: 1.35.0.3
- **対応Kubernetes API**: release-1.35
- **メンテナンス状況**: アクティブ（コミュニティメンテナンス）
- **最終更新日**: 2026年1月18日

このクライアントは、Pod、Service、Deployment、ConfigMapなどのKubernetesリソースの作成、読み取り、更新、削除（CRUD操作）をRubyから実行できます。

## リポジトリの歴史

### 起源と経緯

このリポジトリは、元々Kubernetes公式クライアントプロジェクト（kubernetes-client organization）の一部として2017年5月に開始されました。しかし、2021年3月を最後に約5年間更新が停止していました。

- **fork元リポジトリ**: [kubernetes-client/ruby](https://github.com/kubernetes-client/ruby)
- **このforkでの改変**: OpenAPI再生成に加え、パッケージング調整（`kruby`化）、互換性修正、CI/実行要件更新、ドキュメント整備を実施

### 更新停止期間（2021年3月 - 2026年1月）

公式のKubernetes Ruby Clientは長期間メンテナンスされず、以下の問題がありました：

- Kubernetes 1.20以降のAPIバージョンに対応していない
- 新しいKubernetesリソースタイプが利用できない
- セキュリティアップデートや依存関係の更新が行われていない

### 復活と独立（2026年1月）

2026年1月、このリポジトリは独立したプロジェクトとして復活しました：

- **2026年1月18日**: Kubernetes 1.35対応として再生成
- **リポジトリ**: [github.com/doridoridoriand/k8sruby](https://github.com/doridoridoriand/k8sruby)
- **方針**: コミュニティ主導でメンテナンスを継続

このプロジェクトは公式リポジトリからforkされたスタンドアロン版として、最新のKubernetes APIに対応し続けることを目指しています。


## 対応状況

### Kubernetes APIバージョン

- **対応バージョン**: Kubernetes 1.31-1.35（OpenAPI: release-1.35）
- **クライアントバージョン**: 1.35.0.3
- **最終更新日**: 2026年1月18日

このクライアントは、Kubernetes 1.31-1.35のAPIリソースとエンドポイントに対応しています。

#### Compatibility matrix

| Kubernetes version | Kubernetes API (OpenAPI) | Client gem version |
| --- | --- | --- |
| 1.31 | release-1.35 | 1.35.0.3 |
| 1.32 | release-1.35 | 1.35.0.3 |
| 1.33 | release-1.35 | 1.35.0.3 |
| 1.34 | release-1.35 | 1.35.0.3 |
| 1.35 | release-1.35 | 1.35.0.3 |

### OpenAPI Generatorバージョン

- **使用バージョン**: 5.1.0

クライアントコードは、OpenAPI Generator 5.1.0を使用してKubernetes OpenAPI仕様から自動生成されています。

### 他言語クライアントとの比較

Kubernetesは複数のプログラミング言語向けに公式クライアントを提供しています：

| 言語 | リポジトリ | 最新対応バージョン | メンテナンス状況 |
|------|-----------|-------------------|-----------------|
| **Ruby** | doridoridoriand/k8sruby | 1.35 | コミュニティメンテナンス |
| Python | kubernetes-client/python | 1.31+ | 公式メンテナンス |
| Go | kubernetes/client-go | 1.31+ | 公式メンテナンス |
| Java | kubernetes-client/java | 1.31+ | 公式メンテナンス |
| JavaScript | kubernetes-client/javascript | 1.31+ | 公式メンテナンス |
| C# | kubernetes-client/csharp | 1.31+ | 公式メンテナンス |

### メンテナンス状況

このRubyクライアントは現在、コミュニティ主導でメンテナンスされています：

- ✅ **アクティブ**: 最新のKubernetes APIに対応
- ✅ **更新可能**: OpenAPI Generatorを使用して新しいバージョンへの更新が可能
- ⚠️ **コミュニティベース**: 公式Kubernetesプロジェクトの一部ではありません
- 📝 **貢献歓迎**: プルリクエストやイシューの報告を歓迎します

公式のKubernetes組織によるメンテナンスは停止していますが、このフォークは独立して最新の状態を維持しています。

## ビルド方法

### 前提条件

このgemをビルドして使用するには、以下の環境が必要です：

- **Ruby**: バージョン 3.3.0 以上
- **Bundler**: gemの依存関係管理用（推奨）

Rubyのバージョンを確認：

```bash
ruby --version
```

### リポジトリのクローン

```bash
git clone https://github.com/doridoridoriand/k8sruby.git
cd k8sruby
```

### gemのビルド

リポジトリのルートディレクトリで以下のコマンドを実行してgemをビルドします：

```bash
cd kubernetes
gem build kubernetes.gemspec
```

これにより、`kruby-1.35.0.3.gem`ファイルが生成されます。

### ローカルインストール

ビルドしたgemをローカル環境にインストールします：

```bash
gem install ./kruby-1.35.0.3.gem
```

### 開発用インストール

開発やテストを行う場合は、Bundlerを使用して依存関係をインストールします：

```bash
cd kubernetes
bundle install
```

これにより、以下の依存関係がインストールされます：

- **実行時依存関係**:
  - `typhoeus` (~> 1.0, >= 1.0.1): HTTPクライアントライブラリ

- **開発時依存関係**:
  - `rspec` (~> 3.6, >= 3.6.0): テストフレームワーク

### インストールの確認

インストールが成功したか確認します：

```bash
ruby -e "require 'kruby'; puts Kubernetes::VERSION"
```

正常にインストールされていれば、バージョン番号（例: `1.35.0.3`）が表示されます。

## 使用方法

### 基本的な使い方

Kubernetes Ruby Clientを使用してクラスタに接続し、リソースを操作する基本的な例です。

#### kubeconfigファイルを使用した接続

```ruby
require 'kruby'
require 'pp'

# kubeconfigファイルから設定を読み込む
config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV['KUBECONFIG'], client_configuration: config)

# APIクライアントを作成
client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))

# defaultネームスペースのPod一覧を取得
pp client.list_namespaced_pod('default')
```

#### デフォルトのkubeconfigを使用

環境変数`KUBECONFIG`が設定されていない場合、デフォルトで`~/.kube/config`が使用されます：

```ruby
require 'kruby'

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(client_configuration: config)
client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))
```

### 認証設定

#### kubeconfigファイルを使用

最も一般的な認証方法は、kubeconfigファイルを使用する方法です：

```ruby
require 'kruby'

# 特定のkubeconfigファイルを指定
config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config('/path/to/kubeconfig', client_configuration: config)

client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))
```

#### クラスタ内認証（In-Cluster Config）

Kubernetes Pod内からクライアントを実行する場合、サービスアカウントトークンを使用した認証が可能です：

```ruby
require 'kruby'

config = Kubernetes::Configuration.default_config
Kubernetes.load_incluster_config(client_configuration: config)

client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))
```

### 一般的なAPI操作

#### Podの一覧取得

```ruby
# 特定のネームスペースのPod一覧
pods = client.list_namespaced_pod('default')
pods.items.each do |pod|
  puts "Pod名: #{pod.metadata.name}, ステータス: #{pod.status.phase}"
end

# すべてのネームスペースのPod一覧
all_pods = client.list_pod_for_all_namespaces
```

#### Namespaceの作成と削除

```ruby
require 'kruby'

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV['KUBECONFIG'], client_configuration: config)
client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))

# Namespaceオブジェクトを作成
namespace = Kubernetes::V1Namespace.new({
  kind: 'Namespace',
  metadata: {
    name: 'my-namespace'
  }
})

# Namespaceを作成
client.create_namespace(namespace)

# Namespace一覧を取得
namespaces = client.list_namespace
namespaces.items.each do |ns|
  puts ns.metadata.name
end

# Namespaceを削除
client.delete_namespace('my-namespace')
```

#### リソースの監視（Watch）

Kubernetesリソースの変更をリアルタイムで監視できます：

```ruby
require 'kruby'
require 'pp'

config = Kubernetes::Configuration.default_config
client = Kubernetes::ApiClient.new(config)

watch = Kubernetes::Watch.new(client)

# Namespaceの変更を監視
watch.connect('/api/v1/namespaces') do |obj|
  pp obj
end
```

### サンプルコード

このリポジトリには、実際に動作するサンプルコードが含まれています：

- **`examples/simple/simple.rb`**: 基本的なPod一覧取得の例
- **`examples/namespace/namespace.rb`**: Namespaceの作成・削除の例
- **`examples/watch/watch.rb`**: リソース監視の例

サンプルコードを実行する：

```bash
cd examples/simple
ruby simple.rb
```

### エラーハンドリング

API呼び出しでエラーが発生した場合の処理例：

```ruby
require 'kruby'

begin
  config = Kubernetes::Configuration.default_config
  Kubernetes.load_kube_config(client_configuration: config)
  client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))
  
  pods = client.list_namespaced_pod('default')
  puts "Pod数: #{pods.items.length}"
rescue Kubernetes::ApiError => e
  puts "APIエラー: #{e.message}"
  puts "レスポンスコード: #{e.code}"
rescue StandardError => e
  puts "エラー: #{e.message}"
end
```

## 開発環境

このセクションは、Kubernetes Ruby Clientの開発に貢献したい方向けの情報です。

### 開発環境のセットアップ

#### 1. リポジトリのクローン

```bash
git clone https://github.com/doridoridoriand/k8sruby.git
cd k8sruby/kubernetes
```

#### 2. 依存関係のインストール

Bundlerを使用して開発用の依存関係をインストールします：

```bash
bundle install
```

これにより、以下がインストールされます：
- `typhoeus`: HTTPクライアント（実行時依存）
- `rspec`: テストフレームワーク（開発時依存）

#### 3. 開発用gemのインストール

ローカルで変更したコードをテストする場合：

```bash
gem build kubernetes.gemspec
gem install ./kruby-1.35.0.3.gem
```

### テストの実行

#### RSpecテストの実行

```bash
cd kubernetes
bundle exec rspec
```

特定のテストファイルを実行：

```bash
bundle exec rspec spec/path/to/spec_file.rb
```

#### テストカバレッジの確認

テストを実行すると、コードカバレッジ情報が生成されます（設定されている場合）。

### コード生成

このクライアントは、Kubernetes OpenAPI仕様からOpenAPI Generatorを使用して自動生成されています。

#### クライアントコードの再生成

新しいKubernetesバージョンに対応するためにクライアントを再生成する手順：

1. **生成スクリプトの準備**

   公式のKubernetes code-generatorリポジトリをクローン：

   ```bash
   git clone https://github.com/kubernetes-client/gen.git
   cd gen
   ```

2. **Rubyクライアントの生成**

   リポジトリのルートで以下のコマンドを実行：

   ```bash
   ${GEN_REPO_BASE}/openapi/ruby.sh kubernetes settings
   ```

   - `${GEN_REPO_BASE}`: code-generatorリポジトリのパス
   - `kubernetes`: 出力ディレクトリ
   - `settings`: 設定ファイル

3. **生成されたコードの確認**

   生成後、以下を確認します：
   - APIバージョンが正しいか
   - 新しいリソースタイプが追加されているか
   - 既存の機能が壊れていないか

#### OpenAPI Generator設定

- **バージョン**: 5.1.0（`.openapi-generator/VERSION`に記載）
- **生成元**: Kubernetes OpenAPI仕様（swagger.json）
- **テンプレート**: Ruby用のデフォルトテンプレート

### 貢献方法

#### プルリクエストの作成

1. このリポジトリをフォーク
2. フィーチャーブランチを作成（`git checkout -b feature/amazing-feature`）
3. 変更をコミット（`git commit -m 'Add amazing feature'`）
4. ブランチにプッシュ（`git push origin feature/amazing-feature`）
5. プルリクエストを作成

#### コーディング規約

- Rubyの標準的なスタイルガイドに従う
- 新しい機能には適切なテストを追加
- コミットメッセージは明確で説明的に

#### イシューの報告

バグや機能リクエストは、GitHubのIssuesで報告してください：
- バグ報告には再現手順を含める
- 機能リクエストには使用例を含める
- 環境情報（Rubyバージョン、Kubernetesバージョン）を記載

### 参考リンク

- **Kubernetes API リファレンス**: [https://kubernetes.io/docs/reference/kubernetes-api/](https://kubernetes.io/docs/reference/kubernetes-api/)
- **OpenAPI Generator**: [https://openapi-generator.tech/](https://openapi-generator.tech/)
- **Kubernetes Client 生成ツール**: [https://github.com/kubernetes-client/gen](https://github.com/kubernetes-client/gen)

---

## ライセンス

このプロジェクトは Apache License 2.0 の下でライセンスされています。詳細は [LICENSE](LICENSE) ファイルを参照してください。

## サポート

質問や問題がある場合は、GitHubのIssuesで報告してください：
[https://github.com/doridoridoriand/k8sruby/issues](https://github.com/doridoridoriand/k8sruby/issues)

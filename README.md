# jp_binder_arm64

<div align="center">
<a href="https://mana.bi/">鶴見教育工学研究所</a><br/>
田中 健太
</div>

[rocker/binder](https://github.com/rocker-org/binder) に日本語設定を追加しました。Jupyter Lab (ポート8888) とRStudio Server (8787) がインストールされています。

Apple Silicon (arm64) 向けにビルドしたイメージをDocker Hubに公開しています。以下のコマンドで使用できます。

```
docker pull manabi/jp_binder_arm64
```

ベースにしたrockerリポジトリのライセンスがGPL2なので、本リポジトリもそれに準じます。

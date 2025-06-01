using Pkg
Pkg.activate(".") # カレントディレクトリのプロジェクトをアクティベート

# PackageCompilerがインストールされていない場合はインストール
try
    using PackageCompiler
catch e
    println("PackageCompilerをインストール中...")
    Pkg.add("PackageCompiler")
    using PackageCompiler
end

# 出力先ディレクトリ (例: プロジェクトルートの build フォルダ)
build_dir = joinpath(@__DIR__, "build")
# アプリケーション名
app_name = "ExpCosApp"

println("アプリケーションのコンパイルを開始します...")
println("出力先: $(joinpath(build_dir, app_name))")

try
    create_app(".", joinpath(build_dir, app_name);
               force = true) # 既存のビルドを上書き
    println("コンパイル完了！")
    println("実行ファイルの場所: $(joinpath(build_dir, app_name, "bin", app_name * ".exe"))")
catch e
    println("エラーが発生しました: $e")
    rethrow(e)
end

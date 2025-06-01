module ExpCosApp

using GLMakie

"""
減衰振動可視化アプリケーション
f(t) = exp(-Ct)cos(ωt+φ)の可視化とパラメータ調整
"""

# ========== 定数定義 ==========
const TIME_RANGE = 0:0.01:10
const DEFAULT_C = 0.3
const DEFAULT_ω = 2π
const DEFAULT_φ = π/4
const FIGURE_SIZE = (1000, 700)
const INPUT_WIDTH = 200
const LABEL_WIDTH = 100
const BUTTON_WIDTH = 100

# ========== 数学関数 ==========
"""
減衰振動関数
"""
function damped_oscillation(t, C, ω, φ)
    return exp.(-C .* t) .* cos.(ω .* t .+ φ)
end

"""
Y軸の適切な範囲を計算
"""
function calculate_y_limits(y_values)
    y_min = minimum(y_values)
    y_max = maximum(y_values)
    y_margin = abs(y_max - y_min) * 0.1 + 0.1  # 最小マージンを保証
    return (y_min - y_margin, y_max + y_margin)
end

# ========== UI構築関数 ==========
"""
入力フィールドとラベルを作成
"""
function create_input_controls(fig)
    # 右側のパラメータ入力エリア
    # パラメータラベルと入力フィールド
    Label(fig[1, 2], "C (減衰定数)", width = LABEL_WIDTH)
    textbox_C = Textbox(fig[2, 2], width = INPUT_WIDTH)
    
    Label(fig[3, 2], "ω (角周波数)", width = LABEL_WIDTH)
    textbox_ω = Textbox(fig[4, 2], width = INPUT_WIDTH)
    
    Label(fig[5, 2], "φ (位相)", width = LABEL_WIDTH)
    textbox_φ = Textbox(fig[6, 2], width = INPUT_WIDTH)
    
    # 初期値を設定
    textbox_C.displayed_string[] = string(DEFAULT_C)
    textbox_ω.displayed_string[] = string(round(DEFAULT_ω, digits=3))
    textbox_φ.displayed_string[] = string(round(DEFAULT_φ, digits=3))
    
    return textbox_C, textbox_ω, textbox_φ
end

"""
グラフとその表示要素を作成
"""
function create_graph_components(fig, y_data)
    # 左側のグラフエリア（複数行にまたがる）
    ax = Axis(fig[1:6, 1], 
              xlabel = "時間 t [秒]", 
              ylabel = "f(t)", 
              title = "減衰振動 f(t) = exp(-Ct)cos(ωt+φ)")
    
    # グラフの描画
    lineplot = lines!(ax, TIME_RANGE, y_data, color = :blue, linewidth = 2)
    
    # グリッドの表示
    ax.xgridvisible = true
    ax.ygridvisible = true
    
    return ax, lineplot
end

"""
パラメータ更新処理
"""
function update_parameters!(textbox_C, textbox_ω, textbox_φ, C_obs, ω_obs, φ_obs, y_data, ax)
    try
        # 入力値の解析
        C_val = parse(Float64, textbox_C.displayed_string[])
        ω_val = parse(Float64, textbox_ω.displayed_string[])
        φ_val = parse(Float64, textbox_φ.displayed_string[])
        
        # Observableの更新
        C_obs[] = C_val
        ω_obs[] = ω_val
        φ_obs[] = φ_val
        
        # グラフデータの計算と更新
        new_y_data = damped_oscillation(TIME_RANGE, C_val, ω_val, φ_val)
        y_data[] = new_y_data
        
        # Y軸範囲の動的調整
        y_min, y_max = calculate_y_limits(new_y_data)
        ylims!(ax, y_min, y_max)
        
        # ログ出力
        println("パラメータ更新: C=$C_val, ω=$ω_val, φ=$φ_val")
        println("Y範囲: [$y_min, $y_max]")
        
    catch e
        println("入力値エラー: $e")
        println("有効な数値を入力してください")
    end
end

# ========== メインアプリケーション ==========
function main()
    # Observableの初期化
    C_obs = Observable(DEFAULT_C)
    ω_obs = Observable(DEFAULT_ω)
    φ_obs = Observable(DEFAULT_φ)
    y_data = Observable(damped_oscillation(TIME_RANGE, DEFAULT_C, DEFAULT_ω, DEFAULT_φ))
    
    # Figureの作成
    fig = Figure(size = FIGURE_SIZE)
    
    # UI要素の作成
    textbox_C, textbox_ω, textbox_φ = create_input_controls(fig)
    ax, lineplot = create_graph_components(fig, y_data)
    
    # 更新ボタンの作成（右側の下部に配置）
    update_btn = Button(fig[7, 2], label = "更新", width = BUTTON_WIDTH)
    
    # ボタンクリックイベントの設定
    on(update_btn.clicks) do _
        update_parameters!(textbox_C, textbox_ω, textbox_φ, C_obs, ω_obs, φ_obs, y_data, ax)
    end
    
    # 画面表示
    display(fig)
    
    # 終了待機
    println("Press Enter to close the window...")
    readline()
end

# PackageCompilerのエントリーポイント
function julia_main()::Cint
    main()
    return 0
end

end # module

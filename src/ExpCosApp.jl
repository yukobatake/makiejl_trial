module ExpCosApp

using GLMakie

function julia_main()::Cint
    # 時間範囲
    t_range = 0:0.01:10

    # Observableでパラメータを管理
    C_obs = Observable(0.3)
    ω_obs = Observable(2π)
    φ_obs = Observable(π/4)

    # Figureとレイアウト
    fig = Figure(size = (1000, 700))

    # スライダー
    slider_C = Slider(fig[2, 1], range = 0.1:0.01:2.0, startvalue = 0.3, width = 400)
    slider_ω = Slider(fig[3, 1], range = π:0.05:4π, startvalue = 2π, width = 400)
    slider_φ = Slider(fig[4, 1], range = 0:0.05:2π, startvalue = π/4, width = 400)

    # ラベル
    Label(fig[2, 0], "C (減衰定数)", width = 100)
    Label(fig[3, 0], "ω (角周波数)", width = 100)
    Label(fig[4, 0], "φ (位相)", width = 100)

    # スライダーとObservableを連携
    connect!(C_obs, slider_C.value)
    connect!(ω_obs, slider_ω.value)
    connect!(φ_obs, slider_φ.value)

    # 軸
    ax = Axis(fig[1, 1], xlabel = "時間 t [秒]", ylabel = "f(t)", title = "減衰振動 f(t) = exp(-Ct)cos(ωt+φ)")

    # リアルタイム更新されるグラフ
    lines!(ax, t_range, @lift(exp.(-$C_obs .* t_range) .* cos.($ω_obs .* t_range .+ $φ_obs)), color = :blue, linewidth = 2)

    fig[2, 2] = Label(fig, @lift("C = $(round($C_obs, digits=3))"))
    fig[3, 2] = Label(fig, @lift("ω = $(round($ω_obs, digits=3))"))
    fig[4, 2] = Label(fig, @lift("φ = $(round($φ_obs, digits=3))"))

    ax.xgridvisible = true
    ax.ygridvisible = true

    display(fig)

    println("Press Enter to close the window...")
    readline()
    return 0
end

end # module ExpCosApp

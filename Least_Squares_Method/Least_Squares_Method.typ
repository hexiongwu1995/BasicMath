
#set page(paper: "a4", margin: 1.5cm, numbering: "1/1", number-align: center, fill: rgb("#ffffff32"))

#set document(
  title: [最小二乘法 ( Least Squares Method )],
  author: ("hexiongwu", "Github Copilot"),
  date: datetime(year: 2026, month: 4, day: 20),
)

#show title: set text(size: 14pt, weight: "bold", fill: rgb("#004cff"))
#show title: set align(center)

#set par(spacing: 2em, leading: 1em, justify: false)

#set heading(numbering: "1.")

#show heading.where(level: 1): it => {
  v(1em)
  set text(size: 12pt, weight: "bold", fill: rgb("#0055ff"))
  it
  v(1em)
}

#show heading.where(level: 2): it => {
  set text(size: 10pt, fill: rgb("#0051ff"))
  v(1em)
  it
  v(0.5em)
}

#set text(size: 10pt, lang: "zh", cjk-latin-spacing: auto, font: ("Times New Roman", "KaiTi"))

#set math.mat(row-gap: 1%, column-gap: 1%, align: center)
#set math.vec(gap: 1%, align: center)
#show math.sum: math.limits
#show figure.where(kind: table): set figure.caption(position: top)


#title()


= 简介
最小二乘法是一种通过最小化误差的平方和来找到最佳拟合曲线的数学方法。

== 核心思想

- 假设你有一组数据点，想找一条直线 $y = m x + b$ 来"最好地"描述它们。 每个数据点的真实值 $y_i$ 与模型预测值 $hat(y)_i$ 的差值叫做残差（residual）。

- 记：$z(m,b)= sum_(i=1)^n (y_i - hat(y)_i)^2$ ，其中 $y_i$ 是真实值，$hat(y)_i = m x_i + b$ 是预测值。最小化二乘法的目标是求解函数 $z(m,b)$ 的最小值点。


- 当前计算的是标准最小二乘法（OLS - Ordinary Least Squares），它最小化的是 $y$ 方向残差的平方和，而不是几何意义上的垂直距离。

= 目标：求解函数 $z(m,b)$ 的最小值点


== 将函数 $z(m,b)$ 写成一般的二元二次函数的形式
记：$z= sum_(i=1)^n (y_i - hat(y)_i)^2$ ， 代入：$hat(y)_i= m x_i + b$， 得：\

$
  z & = sum_(i=1)^n (y_i - m x_i -b)^2 \
  & = sum_(i=1)^n (x_i^2 m^2 +2 x_i b m - 2 x_i y_i m + b^2 - 2 y_i b + y_i^2) \
  & = (sum_(i=1)^n x_i^2) dot m^2 + (2 sum_(i=1)^n x_i) dot b dot m - (2 sum_(i=1)^n x_i y_i) dot m + n dot b^2 - (2 sum_(i=1)^n y_i) b + sum_(i=1)^n y_i^2 \
  & = mat(m, b;) mat(sum_(i=1)^n x_i^2, sum_(i=1)^n x_i; sum_(i=1)^n x_i, n;) vec(m, b) - (2 sum_(i=1)^n x_i y_i) dot m - (2 sum_(i=1)^n y_i) b + sum_(i=1)^n y_i^2 \
  & = 1/2 mat(m, b;) mat(2 sum_(i=1)^n x_i^2, 2 sum_(i=1)^n x_i; 2 sum_(i=1)^n x_i, 2 n;) vec(m, b) + mat(- 2 sum_(i=1)^n x_i y_i, - 2 sum_(i=1)^n y_i;) vec(m, b) + sum_(i=1)^n y_i^2 \
  & =: 1/2 bold(alpha)^T A bold(alpha) + bold(beta)^T bold(alpha) + gamma \
$

由于数据集 $(x_i, y_i)$ 为已知量，当 $x_i$ 不全为零时，上式是 z 关于自变量m和b的二元二次函数。

其中：

$bold(alpha)= vec(m, b)$ 是二元二次函数 $z(m,b)$ 的自变量（二维向量）；

$A= mat(2 sum_(i=1)^n x_i^2, 2 sum_(i=1)^n x_i; 2 sum_(i=1)^n x_i, 2 n;)$ 是二元二次函数 $z(m,b)$ 中二次型部分的系数矩阵（2 × 2的实对称矩阵）；

$bold(beta)= vec(- 2 sum_(i=1)^n x_i y_i, - 2 sum_(i=1)^n y_i)$ 是一个二维列向量； $gamma= sum_(i=1)^n y_i^2$ 是一个常数；

根据多元二次函数的极值判别定理，要寻找极值点，需要依次计算一阶和二阶偏导数。


== 计算一阶和二阶偏导数

$ (partial z)/ (partial m) = (2 sum_(i=1)^n x_i^2) dot m + (2 sum_(i=1)^n x_i) dot b - 2 sum_(i=1)^n x_i y_i $

$ (partial z)/ (partial b) = 2 n dot b + (2 sum_(i=1)^n x_i) dot m - 2 sum_(i=1)^n y_i $

$
  (partial^2 z)/ (partial m^2) = 2 sum_(i=1)^n x_i^2 quad quad quad (partial^2 z)/ (partial m partial b) = 2 sum_(i=1)^n x_i
$

$ (partial^2 z)/ (partial b partial m) = 2 sum_(i=1)^n x_i quad quad quad (partial^2 z)/ (partial b^2) = 2 n $

Hessian 矩阵为：
$
  H = mat((partial^2 z)/ (partial m^2), (partial^2 z)/ (partial m partial b); (partial^2 z)/ (partial b partial m), (partial^2 z)/ (partial b^2);)= mat(2 sum_(i=1)^n x_i^2, 2 sum_(i=1)^n x_i; 2 sum_(i=1)^n x_i, 2 n;)
$

注意到： Hessian 矩阵就是二元二次函数 $z(m,b)$ 中二次型部分的实对称矩阵，即 $H= A$。

== 令一阶偏导等于零，求解可能的极值点

令：$(partial z)/(partial m)= (partial z)/(partial b)= 0$，得：

$
  & (sum_(i=1)^n x_i^2) dot m + & (sum_(i=1)^n x_i) dot b & = sum_(i=1)^n x_i y_i \
  & (sum_(i=1)^n x_i) dot m +   &                 n dot b & = sum_(i=1)^n y_i
$

这是一个非齐次的线性方程组，等价的矩阵形式为：

$
  mat(sum_(i=1)^n x_i^2, sum_(i=1)^n x_i; sum_(i=1)^n x_i, n) mat(m; b) = mat(sum_(i=1)^n x_i y_i; sum_(i=1)^n y_i)
$

等式两端同时乘以2得：

$
  mat(2 sum_(i=1)^n x_i^2, 2 sum_(i=1)^n x_i; 2 sum_(i=1)^n x_i, 2 n;) mat(m; b) = mat(2 sum_(i=1)^n x_i y_i; 2 sum_(i=1)^n y_i)
$

注意到等式左侧的系数矩阵即为实对称矩阵 A ，等式右侧向量即为 $- bold(beta)$

则这个非齐次线性方程组可记为： $A mat(m; b) = - bold(beta)$

注意到系数矩阵是一个 2×2 的方阵，即方程的个数与未知量的个数都等于2。

根据克莱姆法则：当 $det(A) != 0$ 时，该方程组有唯一解。这个唯一解对应的就是二元二次函数 $z(m,b)$ 的唯一极值点。

== 求解 $det(A)$ ，判断是否存在唯一极值点（线性方程组的唯一解）

因为：

$
  det(A) & = mat(delim: "|", 2 sum_(i=1)^n x_i^2, 2 sum_(i=1)^n x_i; 2 sum_(i=1)^n x_i, 2 n;) \
         & = 4 (n sum_(i=1)^n x_i^2 - (sum_(i=1)^n x_i)^2) \
         & = 4 n^2 dot 1/n ( sum_(i=1)^n x_i^2 - 1/n (sum_(i=1)^n x_i)^2) \
         & = 4 n^2 dot "Var"(x_i) \
$
其中：$"Var"(x_i)$ 是数据集 $x_i$ 的方差。

当 $x_i$ 不全相等时，$"Var"(x_i) > 0$ ，则： $det(A)= 4 n^2 dot "Var"(x_i) > 0$

方差的数学定义为：

$
  "Var"(x_i) & = 1/n sum_(i=1)^n (x_i - dash(x))^2 \
             & = 1/n (sum_(i=1)^n x_i^2 - (2 sum_(i=1)^n x_i) dot dash(x) + n dash(x)^2) \
             & = 1/n (sum_(i=1)^n x_i^2 - (2 sum_(i=1)^n x_i) dot (1/n sum_(i=1)^n x_i ) + n (1/n sum_(i=1)^n x_i )^2) \
             & = 1/n (sum_(i=1)^n x_i^2 - 2/n (sum_(i=1)^n x_i)^2 + 1/n (sum_(i=1)^n x_i)^2 ) \
             & = 1/n (sum_(i=1)^n x_i^2 - 1/n (sum_(i=1)^n x_i )^2) \
$

由 $det(A) > 0$ $arrow.r.double.long$ 方阵 A 的秩 $r(A)= r(A | - bold(beta))= 2$

由非齐次线性方程组的解的判定定理：线性方程组 $A vec(m, b) = - bold(beta)$ 有唯一解。这个唯一解就是原二元二次函数 $z(m,b)$ 的唯一极值点。

== 通过 Hessian 矩阵 H 的正定性来判定唯一最小值点

由于 Hessian矩阵 $H= A$ ，依次考察 Hessian 矩阵的各阶顺序主子式的情况如下：

当 $x_i$ 不全相等时：$a_(1,1) = 2 sum_(i=1)^n x_i^2 >0$ ， $det(A)> 0$

即：两个顺序主子式都大于零，则：Hessian 矩阵是正定矩阵。

因此：原二元二次函数 $z(m,b)$ 的唯一极值点就是全局的唯一最小值点。

由 Hessian 矩阵的正定性还可以确定：原二元二次函数 $z(m,b)$ 的几何图形为开口朝上的抛物面，存在唯一的最小值点。


== 求解二次型的实对称矩阵 A 的逆矩阵

对于二阶可逆矩阵 $M= mat(a, b; c, d)$，其逆矩阵为：$M^(-1)= 1/ det(M) mat(d, -b; -c, a;)$

则 A 的逆矩阵为：$A^(-1)= 1/ det(A) mat(2 n, - 2 sum_(i=1)^n x_i; - 2 sum_(i=1)^n x_i, 2 sum_(i=1)^n x_i^2)$，

== 求解原二元二次函数 $z(m,b)$ 的最小值点

$
  mat(m; b) &= A^(-1) (bold(-beta)) \
  &= 1/det(A) mat(2 n, -2 sum_(i=1)^n x_i; -2 sum_(i=1)^n x_i, 2 sum_(i=1)^n x_i^2;) vec(2 sum_(i=1)^n x_i y_i, 2 sum_(i=1)^n y_i) \
  &= 1/det(A) mat(4 n sum_(i=1)^n x_i y_i -4 sum_(i=1)^n x_i sum_(i=1)^n y_i; 4 sum_(i=1)^n x_i^2 sum_(i=1)^n y_i -4 sum_(i=1)^n x_i sum_(i=1)^n x_i y_i)
$

其中：

$ det(A)= 4 ( n sum_(i=1)^n x_i^2 - (sum_(i=1)^n x_i)^2 ) $

则，原二元二次函数 $z(m,b)$ 的唯一最小值点为：

$ "m_opt" = (n sum_(i=1)^n x_i y_i - sum_(i=1)^n x_i sum_(i=1)^n y_i)/(n sum_(i=1)^n x_i^2 - (sum_(i=1)^n x_i)^2) $

$
  "b_opt" = (sum_(i=1)^n x_i^2 sum_(i=1)^n y_i - sum_(i=1)^n x_i sum_(i=1)^n x_i y_i)/(n sum_(i=1)^n x_i^2 - (sum_(i=1)^n x_i)^2)
$

#pagebreak()

== 决定系数或拟合优度

英文称为：Coefficient of Determination
$
  R^2 & = 1- "Residual_Squared_Sum" / "Total_Deviation_Squared_Sum" \
      & = 1- ( scripts(sum)_(i=1)^n (y_i - hat(y)_i)^2)/ ( scripts(sum)_(i=1)^n (y_i -dash(y))^2) \
$

决定系数 $R^2$ 是衡量回归模型拟合效果的统计量，取值范围为 $[0, 1]$。

- $R^2 = 1$ 表示模型完美拟合所有数据点，残差为零。
- $R^2 = 0$ 表示模型没有任何解释能力，预测值恒等于 $y$ 的均值 $dash(y)$。
- $R^2$ 越接近 1，说明回归直线对数据的拟合效果越好。

其中，$scripts(sum)_(i=1)^n (y_i - hat(y)_i)^2$ 称为残差平方和（RSS），$scripts(sum)_(i=1)^n (y_i - dash(y))^2$ 称为总离差平方和（TSS），二者之比表示模型未能解释的数据变异占总变异的比例。


= 导入csv文件，处理数据并进行可视化


== 使用表格列出原始数据点
#import "@preview/lilaq:0.6.0" as lq
#import "@preview/numty:0.1.0" as nt
#import "@preview/statastic:1.0.0" as st

#let raw_dict = csv("./Data/linear_relationship.csv", row-type: dictionary)

#let raw_array = csv("./Data/linear_relationship.csv", row-type: array)

#let raw_data = raw_dict.map(it => (float(it.x), float(it.y)))

#let n = raw_data.len()
#let xs = raw_data.map(it => it.at(0))
#let ys = raw_data.map(it => it.at(1))
#let y_mean = st.arrayAvg(ys)

#let sum_x = xs.sum()
#let sum_y = ys.sum()

#let sum_xx = nt.mult(xs, xs).sum()

#let sum_xy = nt.mult(xs, ys).sum()

#let sum_yy = nt.mult(ys, ys).sum()

#let m_opt = (n * sum_xy - sum_x * sum_y) / (n * sum_xx - calc.pow(sum_x, 2))

#let b_opt = (sum_xx * sum_y - sum_x * sum_xy) / (n * sum_xx - calc.pow(sum_x, 2))

#let y_predict = nt.add(nt.mult(m_opt, xs), b_opt)

#let R_Squared = 1 - nt.pow(nt.sub(ys, y_predict), 2).sum() / nt.pow(nt.sub(ys, y_mean), 2).sum()

// 假设导入的 x 数据点是时间序列数据，假设导入的 y 数据点是对应时间序列数据的观测值，比如：应力或者应变，那么对 y 数据点进行统计分析是有意义的，可以得到一些关于数据分布、集中趋势、离散程度等方面的信息，来更好地理解数据的特征和规律。

#let stat = st.arrayStats(ys.map(it => int(it)))

#figure(caption: [原始数据])[
  #table(columns: n + 1, [$x$], ..xs.map(it => str(it)), [$y$], ..ys.map(it => str(it)))
]

// #stat

#let (intMode, ..others) = stat

#figure(caption: [$"y列数据的统计信息"$])[
  #table(
    columns: others.len(), ..others.keys().map(it => $it$), ..others
      .values()
      .map(it => str(calc.round(it, digits: 3)))
      .map(math => $math$)
  ) ]


== 绘制散点图与回归曲线

#align(center)[
  #lq.diagram(
    width: 60%,
    height: 5cm,
    xlabel: [$x$],
    ylabel: [$y$],
    xlim: (0, 10),
    ylim: (0, 25),
    title: [#text(size: 10pt, weight: "bold")[$"Linear Regression"$]],
    legend: (fill: none, stroke: none, position: top + left),
    grid: (stroke: 0.5pt + rgb("#a4a4a43b"), stroke-sub: 0.5pt + rgb("#dcdcdc1b")),
    lq.scatter(xs, ys, label: [$"Original data"$]),
    lq.plot(
      xs,
      y_predict,
      mark: none,
      label: [$"Model:" y = #calc.round(m_opt, digits: 2) x + #calc.round(b_opt, digits: 2) quad R^2 = #calc.round(R_Squared, digits: 3)$],
    ),
  ) ]



#pagebreak()





= 使用 plotsy-3d 绘制 $z(m,b)$ 函数的曲面

plotsy-3d包功能太过简陋，无法在函数曲面上标注最小值点的位置，也无法更改曲面上的网格颜色，也难以调整旋转矩阵以获得更好的视角，所以只能绘制一个大致的函数曲面来展示二元二次函数的形状了。

之后章节会补充使用python中的plotly库绘制的绘制的三维函数曲面图，来更清晰地展示二元二次函数 $z(m,b)$ 的形状，并在曲面上标注最小值点的位置。


#import "@preview/plotsy-3d:0.2.1": plot-3d-surface

#let z(mx, by) = (
  sum_xx * calc.pow(mx, 2) + 2 * sum_x * mx * by - 2 * sum_xy * mx + n * calc.pow(by, 2) - 2 * sum_y * by + sum_yy
)

#let range = 3

#let xmin = calc.floor(m_opt - range)
#let xmax = calc.ceil(m_opt + range)
#let ymin = calc.floor(b_opt - range)
#let ymax = calc.ceil(b_opt + range)

#let color-func(x, y, z, x-lo, x-hi, y-lo, y-hi, z-lo, z-hi) = {
  return blue.transparentize(50%).darken((y / (y-hi - y-lo)) * 20%).lighten((x / (x-hi - x-lo)) * 50%)
}
#align(center)[
  #plot-3d-surface(
    z,
    color-func: color-func,
    subdivisions: 5,
    subdivision-mode: "increase",
    xdomain: (xmin, xmax),
    ydomain: (ymin, ymax),
    scale-dim: (0.08, 0.08, 0.00004),
    axis-step: (1, 1, 1000),
    pad-high: (0, 0, 0), // padding around the domain with no function displayed
    pad-low: (0, 0, 0),
    dot-thickness: 0.05em,
    front-axis-thickness: 0.1em,
    front-axis-dot-scale: (0.05, 0.05),
    rear-axis-dot-scale: (0.008, 0.08),
    rear-axis-text-size: 0.8em,
    axis-label-size: 1.5em,
    xyz-colors: (red, green, blue),
  )
]




= 使用python绘制的 $z(m,b)$ 函数的曲面和等高线图


#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: center + horizon,
  figure(
    link("https://hexiongwu1995.github.io/VS-Code/least_squares_residuals_surface.html")[
      #image("./images/least_squares_residuals_surface.svg", width: 90%)],
    caption: [残差平方和函数 $z(m,b)$ 的形状。 \ #text(size: 6pt)[点击图片会跳转到交互式的三维曲面图]],
  ),
  figure(
    image("./images/least_squares_residuals_contour.svg", width: 90%),
    caption: [残差平方和函数 $z(m,b)$ 的等高线图。\  #text(size: 6pt)[不断收缩的等高线表示函数值不断减小，最终收敛到最小值点的位置]],
  ),
)


#pagebreak()

= 多元二次函数

== 多元二次函数的定义
多元二次函数是指自变量为多个变量 $(x_1, x_2, ..., x_n)$ 的二次多项式，一般形式为：$f(x)= 1/2 sum_(i=1)^n sum_(j=1)^n a_(i,j) x_i x_j + sum_(i=1)^n b_i x_i + c$。多元二次函数的一般形式可以表示为：$f(x) = 1/2 x^T A x + b^T x + c$，其中：

$A = mat(a_(1,1), a_(1,2), dots.h, a_(1,n); a_(2,1), a_(2,2), dots.h, a_(2,n); dots.v, dots.v, dots.down, dots.v; a_(n,1), a_(n,2), dots.h, a_(n,n);)$ 是多元二次函数 $f(x)$ 中二次型部分的 n × n 实对称矩阵 ($A^T = A$)；

$x= vec(x_1, x_2, dots.v, x_n)$ 是一个n维列向量；$b= vec(b_1, b_2, dots.v, b_n)$ 是一个 n 维列向量；$c$ 是一个常数。

关于 A 可以表示成一个实对称矩阵的证明。假设：初始的 $tilde(A)$ 不是一个实对称矩阵， 即存在 $i,j$ 使得 $tilde(a)_(i,j) != tilde(a)_(j,i)$。

可令： $a_(i,j) = a_(j,i) = (tilde(a)_(i,j) + tilde(a)_(j,i))/2$，则：$A = (tilde(A) + tilde(A)^T)/2$ 必定为一个实对称矩阵。

而且，可以证明，对于任意的 $x$，有: $x^T A x = x^T (tilde(A) + tilde(A)^T)/2 x= ((x^T tilde(A) x) + (x^T tilde(A)^T x) )/2= ( (x^T tilde(A) x) + (x^T tilde(A) x)^T )/2 = x^T tilde(A) x$。即：初始的非实对称矩阵 $tilde(A)$ 可以表示成一个实对称矩阵的形式 $A$。

== 二次型

二次型的定义：如果一个二次多项式 $f(x)$ 中只含二次项的部分，没有一次项和常数项，即 $b= bold(0)$ 和 $c= 0$，则称 $f(x)$ 是一个二次型。

二次型的一般形式为：$Q(x) = x^T A x$，其中 $A$ 是一个 n × n 的实对称矩阵。


== 正定矩阵

对于一个 n × n 的方阵 $A$，如果对于任意非零向量 $x$，都有 $x^T A x > 0$, 则称 $A$ 是一个正定矩阵。即：
$ "方阵 A 称为正定矩阵" arrow.l.r.double.long Q(x)= x^T A x > 0 "对于任意非零向量 x 成立。" $

正定矩阵的性质：
- 正定矩阵的特征值全为正数。
- 正定矩阵是可逆的，且其逆矩阵也是正定矩阵。

== 正定矩阵的判定定理

+ 顺序主子式判定法(Sylvester's criterion)：
  - A 正定 $arrow.l.r.double.long$ A 的所有顺序主子式都大于零
  - A 负定 $arrow.l.r.double.long$ A 的所有顺序主子式交替正负（1阶负，2阶正，3阶负，依此类推...）

+ 特征值判定法：
  - A 正定 $arrow.l.r.double.long$ A 的所有特征值都大于零
  - A 负定 $arrow.l.r.double.long$ A 的所有特征值都小于零

== Hessian 矩阵

Hessian 矩阵的定义：对于一个多元函数 $f(x)$ （其中 $x$ 是一个 n 维列向量），其 Hessian 矩阵 $H$ 是一个 n × n 的矩阵，其中第 i 行第 j 列的元素为 $H_(i,j) = (partial^2 f)/(partial x_i partial x_j)$，即 $f$ 关于 $x_i$ 和 $x_j$ 的二阶偏导数。即：

$
  H = mat((partial^2 f)/(partial x_1^2), ..., (partial^2 f)/(partial x_1 partial x_n); (partial^2 f)/(partial x_2 partial x_1), ..., (partial^2 f)/(partial x_2 partial x_n); dots.v, dots.down, dots.v; (partial^2 f)/(partial x_n partial x_1), ..., (partial^2 f)/(partial x_n^2))
$

对于多元二次函数 $f(x) = 1/2 x^T A x + b^T x + c$，其 Hessian 矩阵 $H$ 就是实对称矩阵 $A$。因此：对于多元二次函数 $f(x)$，有：$H = A$。

备注：

- 当 A 是实对称矩阵，即当：$A^T = A$ 时，有：$gradient_x (1/2 x^T A x) = A x$ （这是关于 x 的一阶梯度），对梯度再求导即得 Hessian 矩阵 $H=A$ 。
- 对于多元二次函数 $f(x) = 1/2 x^T A x + b^T x + c$，
 - 第一步（求梯度）：$gradient_x f = A x + b$ 
 - 第二步（对梯度求雅可比）：$H = J(gradient_x f) = (partial (A x + b))/ (partial x) = A$
- 所以 Hessian 矩阵 $H=A$ 的本质就是：对一阶梯度（向量值函数）再求一次雅可比矩阵。


== 多元二次函数的极值判别定理

对于一个多元二次函数 $f(x) = 1/2 x^T A x + b^T x + c$，其 Hessian 矩阵就是 $A$，且 $A$ 是常数矩阵。

- 若 $A$ 正定，则 $f$ 只有一个极小值点（全局极小值），且极值点唯一。
- 若 $A$ 负定，则 $f$ 只有一个极大值点（全局极大值），且极值点唯一。
- 若 $A$ 既不正定也不负定，则极值点不是极小/极大值点（可能是鞍点）。

在最小二乘法的情形下，$A$ 的主对角线元素（如 $sum x_i^2$ 和 n）都大于零，且 $A$ 可证正定，所以极值点唯一且为全局极小值。此时不需要再单独判断 Hessian 是否正定，但在更一般的二次型极值问题中，仍需判断 Hessian 的正定性。




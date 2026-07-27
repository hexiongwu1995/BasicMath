
#import "../../template/template.typ": conf
#import "@preview/cetz:0.5.0"
#import "@preview/gentle-clues:1.3.1": *

#show: conf.with(
  title: "弦上波的数学模型",
  author: "何雄武",
  date: datetime.today(),
)


= 真实物理模型

+ 如@Schematic_Diagram_of_wave_on_a_string 所示，一根琴弦的两端被固定，弦长为$L(t)$，琴弦的线密度为$mu(x, t)$，弦上张力为$T(x,t)$。
+ 初始时刻$t=0$，将琴弦的位置$x_0$处向上拉伸至一个高度$A_0$，然后立刻释放琴弦。
+ 目标是求解琴弦的振动方程$y(x,t)$和琴弦单位长度上的回复力$f_y (x,t)$。

= 模型假设

+ 小振幅假设：将初始振幅$A_0$限定在较小的范围，比如：$A_0 /(L_0) lt.double 1%$ ?
+ 小角度假设：弦上任意位置的斜率 $|(partial y) / (partial x)| lt.double 1$，为后续所有线性化处理奠定基础。
+ 在求解琴弦张力的竖直分量时，需要做两个近似：
  - 忽略琴弦的伸长，将$L(t)$近似为$L_0$
  - 将琴弦上的张力$T(x,t)$的模长近似为静止时的琴弦预张力$T_0$的模长。
+ 在求解琴弦上的回复力时，同样需要将琴弦上的张力$T(x,t)$近似为静止时的琴弦预张力$T_0$。
+ 将琴弦上任意位置$x$处的线密度$mu(x, t)$近似为琴弦静止时的线密度$mu_0$。
+ 将$t=0$ 时刻的琴弦形状近似为三角形。
+ 忽略空气阻力、内部摩擦、支点能量损失等阻尼效应。




// CeTZ 绘图参数
#let L = 15
#let A = 0.5
#let H = 2
#let R = 1
#let bez-contr = (4, 1)
#let tube-pos = (10, 5)


// 真实数学建模时需要使用到的默认参数（与Javascript进行数据共享）
#let A_0 = 0.01           // 初始振幅，单位为 m，参数滑块数据范围：(0.001, 0.01)
#let L_0 = 0.6            // 弦长，单位为 m，参数滑块数据范围：(0.6, 0.8)
#let x_rel = 0.1          // 相对拨弦位置，无量纲，参数滑块数据范围：(0.1, 0.9)
#let x_0 = x_rel * L_0    // 拨弦位置，单位为 m，由相对拨弦位置计算得到
#let T_0 = 80             // 预张力，单位为 N，参数滑块数据范围：(70, 100)
#let mu_0 = 0.01          // 线密度，单位为 kg/m，参数滑块数据范围：(0.004, 0.01)
#let N_terms = 50           // 级数截断项数，无量纲，参数滑块数据范围：(1, 100)
#let simSpeed = 1e-4             // 动画速度系数，无量纲，参数滑块数据范围：(1e-4, 1e-3)



#figure(caption: [弦上波的示意图])[

  #align(center)[
    #cetz.canvas({
      import cetz.draw: *
      // 弦静止时的状态
      line((0, 0), (L, 0), stroke: (paint: gray, thickness: 2pt))
      // 绘制t=0时刻的三角波
      line((0, 0), (2, 0.35), (L, 0), stroke: (paint: rgb("#8d8d8d")), name: "Ini_Tri_Wave")
      circle((2, 0.35), radius: 0.2, name: "string_piece", stroke: (
        paint: rgb("#9d9d9d"),
        thickness: 1pt,
        dash: "dotted",
      ))
      circle(tube-pos, radius: 3, name: "string_detail")

      line("string_piece.10%", "string_detail.13%", stroke: (paint: rgb("#bcbcbc9a"), thickness: 1pt, dash: "dashed"))
      line("string_piece.55%", "string_detail.53%", stroke: (paint: rgb("#c0c0c0c3"), thickness: 1pt, dash: "dashed"))

      group({
        set-origin(tube-pos)
        line((-1.8, -1.7), (1.8, -1.7), mark: (end: (symbol: "stealth", fill: black)), name: "xaxis")
        move-to("xaxis.end")
        content((rel: (0.2, 0)), $x$)
        stroke(gray)
        // circle((0, 0), radius: 1pt)
        rotate(20deg)
        scale(0.8)
        arc((-1, -0.3), start: -90deg, stop: 90deg, radius: (0.1, 0.3), stroke: (
          paint: rgb("#5e5e5e8a"),
          dash: "densely-dotted",
        ))
        arc((1, 0.3), start: 90deg, stop: 270deg, radius: (0.1, 0.3), stroke: (paint: rgb("#5e5e5e8a"), dash: "solid"))
        merge-path(close: true, fill: rgb("#d6d6d67b"), stroke: rgb("#5e5e5e8a"), {
          // circle((0,0), radius:2pt, fill:orange, stroke:none)
          arc((-1, -0.3), start: 270deg, stop: 90deg, radius: (0.1, 0.3), name: "left")
          bezier((-1, 0.3), (1, 0.3), (0, 0.5))
          arc((1, 0.3), start: 90deg, stop: -90deg, radius: (0.1, 0.3), name: "right")
          bezier((1, -0.3), (-1, -0.3), (0, -0.1))
        })

        line("left.origin", (rel: (-2, 0)), mark: (end: (symbol: "stealth", fill: gray, scale: 0.5)), name: "a")
        line("right.origin", (rel: (2, 0)), mark: (end: (symbol: "stealth", fill: gray, scale: 0.5)), name: "b")
        rotate(-20deg)
        line("left.origin", (rel: (-2, 0)), stroke: (dash: "densely-dotted"), name: "c")
        line("right.origin", (rel: (2, 0)), stroke: (dash: "densely-dotted"), name: "d")
        cetz.angle.angle(
          "a.start",
          "a.end",
          "c.end",
          direction: "cw",
          radius: 80%,
          mark: (end: (symbol: "stealth", scale: 0.3)),
          label: $alpha$,
          label-radius: 80%,
        )
        cetz.angle.angle(
          "b.start",
          "b.end",
          "d.end",
          direction: "cw",
          radius: 80%,
          mark: (end: (symbol: "stealth", scale: 0.3)),
          label: $beta$,
          label-radius: 80%,
        )
        anchor("HL", (project: "left.origin", onto: ("xaxis.start", "xaxis.end")))
        anchor("HR", (project: "right.origin", onto: ("xaxis.start", "xaxis.end")))
        anchor("HC", (project: (0, 0), onto: ("xaxis.start", "xaxis.end")))
        set-style(stroke: (dash: "densely-dotted"))
        line("left.origin", (rel: (0, -25pt), to: "HL"))
        line("right.origin", (rel: (0, -25pt), to: "HR"))
        line((0, 0), "HC", mark: (start: (symbol: "stealth", scale: 0.5)), name: "y")
        set-style(content: (frame: "rect", fill: white, strike: none, padding: 1pt))
        // content("yaxis.mid", $y$)
        set-style(stroke: none)
        content("a.end", $T_1$, anchor: "east")
        content("b.end", $T_2$, anchor: "west")
        set-style(content: (frame: "rect", fill: white))
        content((rel: (0, -2pt), to: "HC"), $x$, anchor: "north")

        line(
          (rel: (0, -20pt), to: "HL"),
          (rel: (0, -20pt), to: "HR"),
          stroke: (paint: gray),
          mark: (symbol: "stealth", scale: 0.3),
          name: "Delta",
        )
        content("Delta.mid", $Delta x$)
        content("y.mid", $y$)
      })
      rect((-0.1, -H / 2), (0.1, H / 2), fill: gradient.linear(gray, white))
      rect((L - 0.1, -H / 2), (L + 0.1, H / 2), fill: gradient.linear(gray, white))
    })]
]<Schematic_Diagram_of_wave_on_a_string>





= 微元受力分析

== 建立坐标系
如@Schematic_Diagram_of_wave_on_a_string 所示，将静止时琴弦的水平向右方向取为$x$轴正向，竖直向上的方向取为$y$轴正向，取琴弦的左侧固定点作为坐标系原点。

== 取一小段微元做受力分析

在琴弦的任意位置$x$处取一段微元，长度为$Delta x$，质量近似为$mu_0 Delta x$。由于这段微元在实际的振动过程中几乎只沿$y$方向振动，在$x$方向的位移很小，因此，可近似将该段微元在$x$方向的合外力视为零？


即：$T_2 cos(beta) - T_1 cos(alpha) =0$ <x-component>

记：$ T_x = T_1 cos(alpha) = T_2 cos(beta) $ <x-constant>

这段微元在$y$方向的受力情况为：

$ T_2 sin(beta) - T_1 sin(alpha) = mu_0 Delta x (partial^2 y)/(partial t^2) $<y-component>

#abstract(title: "等式右侧是否需要带负号？")[
  上述等式@y-component  是根据牛顿第二定律 $F = m a$，分别在等式两侧代入定义表达式后得到，不需要考虑符号。
  右侧的表达式$(partial^2 y)/(partial t^2)$ 就是加速度的定义，不需要额外添加符号。
]

在等式 @y-component 两端同时除以 $T_x$得：

$
  (T_2 sin(beta))/(T_2 cos(beta)) - (T_1 sin(alpha))/(T_1 cos(alpha)) = (mu_0 Delta x)/(T_x) dot (partial^2 y)/(partial t^2)
$

等价变形得： $ (tan(beta) - tan(alpha) )/(Delta x) = mu_0 / T_x dot (partial^2 y)/(partial t^2) $<slope>

进一步变形得：$ ( lr((partial y)/(partial x)|)_(x+ 0.5 times Delta x) - lr((partial y)/(partial x) |)_(x - 0.5 times Delta x) )/(Delta x) = mu_0/T_x dot (partial^2 y)/(partial t^2) $ <Second-Partial-Derivative>

等式 @Second-Partial-Derivative 左侧是 y 对 x的二阶偏导。整理得：


$ (partial^2 y)/(partial x^2) = mu_0/T_x dot (partial^2 y)/(partial t^2) $<wave_equation>

#question(title: [琴弦张力的水平分量$T_x$是否等于琴弦的静止预张力$T_0$？])[
  上式@wave_equation 是琴弦振动的波动方程，其中：$mu_0$是琴弦静止状态下的线密度，$T_x$是琴弦振动时的张力在水平方向上的分量，不确定它是否等于琴弦静止状态下的预张力$T_0$？

  GPT-5.5 解答：由 @x-constant 可知，当忽略x方向的加速度时，琴弦振动时，琴弦上各个位置处的张力的水平分量为恒定值$T_x$。在小振幅、忽略弦伸长和水平运动的线性模型中，$T_x$ 可近似等于静止预张力 $T_0$。即，在小振幅线性波动方程中，可以取 $T_x approx T_0$。在有限振幅或非线性模型中，不能严格认为二者恒等。
]


= 解偏微分方程


等式 @wave_equation 可以写成如下形式：

#abstract(title: [波动方程])[
  $
    (partial^2 y)/(partial x^2) &= mu_0/T_0 dot (partial^2 y)/(partial t^2) #linebreak() &= 1/c^2 (partial^2 y)/(partial t^2) #h(1cm) inline(c= sqrt(T_0/mu_0) "是波速")
  $<Wave_Equation>]


这是一个二阶线性偏微分方程，尝试使用分离变量法求解：

假设函数$y(x,t)$可以写成这种分离变量的形式：$ y(x,t) = X(x) dot T(t) $<seperation_of_variables>


注意：这里的$T(t)$指的不是张力T随时间t变化的函数，而是关于单一自变量-时间t的未知函数。

对x求导得：$(partial y)/(partial x) = T(t) (d X)/(d x)$

继续对x求导得：$(partial^2 y)/(partial x^2) = T(t) (d^2 X)/(d x^2)$

同理可得：$(partial^2 y)/(partial t^2) = X(x) dot (d^2 T)/(d t^2)$

代入 @Wave_Equation 得：$ T(t) (d^2 X)/(d x^2) = 1/c^2 dot X(x) (d^2 T)/(d t^2) $

等式两端同除 @seperation_of_variables 得：$ 1/X dot (d^2 X)/(d x^2) = 1/c^2 dot 1/T (d^2 T)/(d t^2) $

由于等式左侧仅与自变量x有关，等式右侧仅与自变量t有关。当 x 和 t 独立变化时，要使等式恒成立，两侧只能等于同一个常数C。令等式两侧都等于常数C可得如下微分方程组。

#question(title: [这里是否需要考虑C是虚数或复数的情况？])[
  答：不需要考虑C是虚数或复数的情况，因为目标函数y(x,t)是一个实函数，而且，波动解的物理意义要求X(x)与T(t)都是实函数。因此，只需要考虑常数C为实数的情况。而且，即使强行引入复数情况，也无法同时满足实边界条件和实初值条件。
]

== 解微分方程组

#abstract(title: [二阶常系数齐次线性微分方程组])[
  方程 @Eq-Space 对应的是空间部分，方程 @Eq-Time 对应的是时间部分。
  $ (d^2 X)/(d x^2) - C X =0 $<Eq-Space>

  $ (d^2 T)/(d t^2) - C dot c^2 dot T = 0 #h(1cm) "其中：" c = sqrt(T_0/mu_0) $<Eq-Time>
]

== 微分方程组的边界条件

由于物理模型是一个两端被固定的琴弦，这对应的边界条件是：


#set math.cases(reverse: true, gap: 1em)

$ cases(y(0,t)= X(0)T(t)= 0, T(t)"为非零解")#h(1cm) arrow.r.double.long #h(1cm) X(0)=0 $<BCs_0>

$ cases(y(L_0, t) = X(L_0)T(t) =0, T(t) "为非零解") #h(1cm) arrow.r.double.long #h(1cm) X(L_0) =0 $<BCs_L0>



== 求解空间微分方程

对于空间部分的微分方程 @Eq-Space ，相应的特征方程为：$r^2 = C$， 特征方程的解为：$r_(1,2) = plus.minus sqrt(C)$

当 $C > 0$时，对应的微分方程的通解为：$X(x) = C_1 e^(sqrt(C)x) + C_2 e^(-sqrt(C)x)$

当 $C = 0$时，对应的微分方程的通解为：$X(x) = C_1 + C_2 x$

当 $C < 0$时，对应的微分方程的通解为：$X(x) = C_1 cos(sqrt(-C)x) + C_2 sin(sqrt(-C)x)$

#abstract(
  title: [注意],
)[这里的$C_1$和$C_2$都必须是实常数，因为原微分方程中的函数X(x)是实函数，系数C也是实数，对于实初值条件，解也一定是实函数，这要求通解形式能产生实函数。]




#{
  set text(size: 0.8em)

  table(
    columns: 5,
    inset: 1em,
    fill: (_, y) => { if y == 0 { rgb("#79bdc946") } else { none } },
    align: (x, y) => { if x == 2 and y != 0 { right + horizon } else { center + horizon } },
    "常数C", "通解形式", "代入边界条件", "系数", "满足边界条件的特解",
    [$C>0$],
    [$X(x) = C_1 e^(sqrt(C)x) + C_2 e^(-sqrt(C)x)$],
    [$cases(C_1 + C_2 =0, C_1(e^(sqrt(C) L_0)- e^(-sqrt(C) L_0))=0, L_0 >0)$],
    [$C_1 =C_2=0$],
    [$X(x)=0$],

    [$C=0$], [$X(x) = C_1 + C_2 x$], [$cases(C_1 =0, C_2 L_0=0, L_0>0)$], [$C_1=C_2=0$], [$X(x)=0$],
    [$C<0$],
    [$X(x) = C_1 cos(sqrt(-C)x) + C_2 sin(sqrt(-C)x)$],
    [$cases(C_1=0, C_2 sin(sqrt(-C) L_0)=0, L_0>0)$],
    [可令$C = -k^2, k>0$ \ 得：$k= (n pi)/L_0$],
    [得非零特解：$X_n (x) = C_(2, n) sin((n pi)/L_0 x)$ \ 其中$C_(2, n)$可取任意常数 \ 其中 $n in NN^+$],
  )
}

即，满足边界条件的空间微分方程的特解为：
$ X_n (x) =C_(2, n) sin(k_n x) #h(1cm) "其中：" k_n = (n pi)/L_0 $<Particular_Solution_of_Space_Differential_Equation>




#abstract(title: [空间微分方程的解])[
  X(x)可以取下面这种通解形式，但是由这种通解形式构造出的完整解形式太复杂，不利于在代入初始三角波条件后求解系数。因此，需要先构造出特殊的完整解形式，然后代入初始的三角波条件求解系数。
  $
    cancel(X(x) = sum_(n=1)^(infinity) C_(2, n) sin(k_n x) #h(1cm) "其中：" k_n = (n pi)/L_0, cross: #true)
  $<Solution_of_Space_Differential_Equation>
]


== 微分方程组的初始条件

// 这个位置初始条件隐含在初始三角波的初始条件当中
// $
//   y(x_0, 0)= X(x_0) T(0) = A
// $<Initial_Condition_position>

$
  cases(lr((partial y)/(partial t)|)_(t=0) = X(x) dot lr((d T)/(d t) |)_(t=0) =0, X(x) equiv.not 0) #h(1cm) arrow.double.long.r #h(1cm) lr((d T)/(d t)|)_(t=0) =0
$<Initial_Condition_velocity>

#set math.cases(reverse: false)
$
  y(x,0)= X(x) T(0)= cases(A_0/x_0 x #h(3.7cm) 0<= x<= x_0, A_0/(L_0 - x_0) (L_0 - x) #h(1.9cm) x_0 < x <= L_0)
$<Initial_Triangle_Wave>


== 求解时间微分方程

对于时间微分方程 @Eq-Time ，相应的特征方程为：$r^2 - c^2 dot C=0$，代入 $C= -k_n^2, #h(1em) k_n= (n pi)/L_0$，解得：

$ r_(1,2)= plus.minus i dot c dot k_n $

则时间微分方程的特解为：

$ T_n (t)= D_(1, n) cos(omega_n t) + D_(2, n) sin(omega_n t) #h(1cm) "其中：" omega_n = c dot k_n $

对时间t求导得：

$ (d T_n )/(d t) = D_(2, n) omega_n cos(omega_n t) - D_(1, n) omega_n sin(omega_n t) $

代入初始速度条件 @Initial_Condition_velocity ，解得：$D_(2, n) =0$

因此：$ T_n (t) = D_(1, n) cos(omega_n t) #h(1cm) "其中：" omega_n = c dot k_n #h(1cm) k_n= (n pi)/L_0 $

为了确定系数 $D_(1, n)$和$C_(2, n)$，需要先构造完整解形式。

== 构造完整解

由于每一个 $X_n (x) dot T_n (t) = C_(2,n) sin(k_n x) dot D_(1,n) cos(omega_n t)$ 都是波动方程 @Wave_Equation 的线性无关的特解，则可取 $y(x,t)$的通解形式为：

$
  y(x, t) & = sum_(n=1)^(infinity) X_n (x) T_n (t) #linebreak() & = sum_(n=1)^(infinity) (C_(2, n) D_(1, n) sin(k_n x) cos(omega_n t) ) #h(1cm)
$

其中：  $k_n = (n pi)/L_0 #h(1cm) omega_n = c dot k_n #h(1cm) n in NN^+$

则：

$ y(x,0) = sum_(n=1)^(infinity) (C_(2, n) D_(1, n) sin((n pi)/L_0 x)) $

结合等式 @Initial_Triangle_Wave 得：

$
  sum_(n=1)^(infinity) (C_(2, n) D_(1, n) sin((n pi x)/L_0)) = cases(A_0/x_0 x #h(3.7cm) 0<= x<= x_0, A_0/(L_0 - x_0) (L_0 - x) #h(1.9cm) x_0 < x <= L_0)
$<Fourier_Series_Form>

这是一个傅里叶正弦级数展开的形式，可以由傅里叶正弦级数的系数公式确定 $C_(2, n) D_(1, n)$的值。

对比傅里叶正弦级数的展开形式可知：

#text(size: 8pt)[$
  b_n &= C_(2, n) D_(1, n) #linebreak() &= 2/L_0 integral_(0)^(L_0) y(x,0) sin((n pi x)/L_0) d x #linebreak() &= 2/L_0 (A_0/x_0 integral_0^(x_0) x sin((n pi x)/L_0) d x + (A_0 L_0)/(L_0 -x_0) integral_(x_0)^(L_0) sin((n pi x)/L_0) d x - A_0/(L_0 - x_0) integral_(x_0)^(L_0) x sin((n pi x)/L_0) d x ) #linebreak() &= (2A_0)/(L_0 x_0) integral_0^(x_0) x sin(k_n x) d x + (2A_0)/(L_0 - x_0) integral_(x_0)^(L_0) sin(k_n x) d x - (2A_0)/(L_0 (L_0 - x_0)) integral_(x_0)^(L_0) x sin(k_n x) d x #linebreak() &= - (2A_0)/(L_0 x_0 k_n) ( (x cos(k_n x)) lr(|, size: #200%)_0^(x_0) - integral_0^(x_0) cos(k_n x) d x) - (2A_0)/((L_0 - x_0)k_n) cos(k_n x) lr(|, size: #200%)_(x_0)^(L_0) + (2A_0)/(L_0 (L_0 - x_0) k_n) (x cos(k_n x) lr(|, size: #200%)_(x_0)^(L_0) - integral_(x_0)^(L_0) cos(k_n x) d x) #linebreak() &= - (2A_0)/(L_0 x_0 k_n) (x_0 cos(k_n x_0) - 1/k_n sin(k_n x_0)) - (2A_0)/((L_0 -x_0)k_n) (cos(k_n L_0) - cos(k_n x_0)) #linebreak() & + (2A_0)/(L_0(L_0 - x_0)k_n) (L_0 cos(k_n L_0) - x_0 cos(k_n x_0) - 1/k_n (sin(k_n L_0) - sin(k_n x_0)))
  #linebreak() &= 2(- A_0/(L_0 k_n) + A_0/((L_0 - x_0)k_n) - (A_0 x_0)/(L_0(L_0 - x_0)k_n)) cos(k_n x_0) + 2(- A_0/((L_0 - x_0)k_n) + A_0/((L_0 - x_0)k_n))cos(k_n L_0) #linebreak() & + 2(A_0/(L_0 x_0 k_n^2) + A_0/(L_0 (L_0 -x_0) k_n^2)) sin(k_n x_0) - (2A_0)/(L_0(L_0 - x_0) k_n^2) sin(k_n L_0)
  #linebreak() &= 0 + 0 + (2A_0)/(L_0 k_n^2) dot L_0/(x_0(L_0- x_0)) sin(k_n x_0) - 0
  #linebreak() &= (2A_0)/(x_0(L_0 - x_0) k_n^2 ) sin(k_n x_0) #h(1cm) "其中：" k_n= (n pi)/L_0 #linebreak() &= (2 A_0 L_0^2)/(x_0(L_0 - x_0) pi^2 n^2) sin((n pi x_0)/L_0)
$]



#abstract(title: [满足所有边界条件和初始条件（初始三角波）的完整解$y(x,t)$为：])[
  $
    y(x,t) & = sum_(n=1)^(infinity) X_n (x) T_n (t) #linebreak() & = underbrace(sum_(n=1)^(infinity) (b_n sin(k_n x) cos(omega_n t)), "驻波") #linebreak() &= 1/2 sum_(n=1)^(infinity) (b_n ( underbrace(sin(k_n x + omega_n t), "左行波") + underbrace(sin(k_n x - omega_n t), "右行波") ) )
  $<Complete_Solution>

  核心物理意义：两端固定的弦在初始三角波激励下的自由振动，可以分解为无穷多个简正模态的驻波叠加，而每个驻波又可以进一步分解为一对反向传播的行波。系数 $b_n$ 随 $1/n^2$衰减，说明高阶谐波的贡献迅速减小，实际振动主要由前几阶模态主导。
]


#abstract(title: [驻波形式（级数叠加和模态分析）])[
  物理意义：
  - 每个 n 对应一个谐波（第 n 阶模态），弦的振动被分解为无穷多个驻波模式（即简正模）的线性叠加：
    - $sin(k_n x)$：空间形状因子（波节在两端，中间有 n−1 个节点），决定了弦上各点的振动幅度分布（波节和波腹位置固定）。
    - $cos(omega_n t)$：时间振动因子，$omega_n$为角频率，决定了每个模态随时间简谐振动的快慢。
    - $b_n$：该模态的振幅系数（由初始三角波决定）
  - 驻波的特点是波节和波腹位置固定，不随时间移动。
]

#abstract(title: [行波形式])[
  利用三角恒等式$sin A cos B = 1/2 (sin(A+B)+sin(A−B))$，将驻波分解为两个反向传播的行波：

  - $sin(k_n x + omega_n t)$：左行波（向左传播，+ 号表示波随时间增加向左移动）
  - $sin(k_n x - omega_n t)$：右行波（向右传播，− 号表示波随时间增加向右移动）
  - 这表明：驻波可以看作两列振幅相同、传播方向相反的行波的叠加，这是波动理论中的一个核心结论。
]




其中：

$ b_n = (2 A_0 L_0^2)/(x_0(L_0 - x_0) pi^2 n^2) sin(k_n x_0) #h(1cm) n in NN^+ $

$ k_n = (n pi)/L_0 $

$ omega_n = c dot k_n $


注意到：$k_n lambda_n = 2 pi$， $omega_n T_n = 2 pi$ （这里的$T_n$代表时间周期）

因此，$k_n$称为波数？？？ $omega_n$称为角频率，$c= sqrt(T_0/mu_0)$称为波速（相速度）。

可以确认：$k_n$ 确实被称为波数（angular wave number），这是标准物理术语。

= 求解思路解析

求解思路正确，边界条件和初始条件是偏微分方程定解问题的两个独立组成部分。

- 边界条件决定了空间基函数（特征函数系）
- 初始条件决定了叠加系数（以及时间演化形式)

#table(
  columns: 3,
  inset: 1em,
  fill: (_, y) => { if y == 0 { rgb("#79bdc946") } else { none } },
  align: left + horizon,
  table.header("", "边界条件", "初始条件"),
  [约束对象], [$X(x)$（空间函数）], [$T(t)$ 和 $b_n$（时间函数和系数）],
  [时间范围], [对所有 $t≥0$], [仅在 $t=0$],
  [在分离变量法中的角色], [确定特征值 $k_n$ 和特征函数 $sin(k_n x)$], [确定傅里叶系数 $b_n$ 和时间函数 $T_n (t)$],
  [物理意义], [决定弦的振动模式（驻波形状）], [决定每个模式的振幅和时间演化],
)

= 琴弦上的张力在竖直方向上的分量 $T_y (x, t)$

#abstract(title: "张力的严格数学定义")[
  如弦上波模型的示意图 @Schematic_Diagram_of_wave_on_a_string 所示：
  - 取微元段右侧截面处受到的截面右侧弦的拉力作为张力$arrow(T)(x,t) = |T(x,t)| vec(cos theta, sin theta)$。
  - 根据这个定义，张力的竖直分量

  $
    T_y (x,t) &= arrow(T)(x,t) dot hat(y) #linebreak() &= |T(x,t)| vec(cos theta, sin theta) dot vec(0, 1) #linebreak() &= |T(x,t)| sin theta
  $

  - 张力的竖直分量的方向是否总与位移的方向相反？类似于弹簧的回复力？
  - 提供回复力的不是单点的 $T_y$ ，而是微元段两端 $T_y$ 的差值（净力）。所以净力确实与位移相反（回复力），但单点的 $T_y$ 不是这样。
]

则：

$
  T_y (x, t) & = |T(x, t)| dot sin [theta^#footnote[$theta$ 是指弦的切线方向与水平线之间的夹角 $- pi/2 < theta < pi/2$] (x, t)] #linebreak() & = |T(x, t)| dot cos[theta(x, t)] dot tan[theta(x, t)]
$



#abstract(title: [近似])[
  由小振幅假设：
  - 将 $cos(theta(x, t))$ 近似为 1
  - 将琴弦上的张力的模长 $|T(x ,t)|$近似为静止预张力$T_0$
]

则：

$ T_y (x,t) & = T_0 tan(theta(x, t)) $

$ T_y (x,t) = T_0 dot (partial y)/(partial x) $<Y_component_of_Tension>


对等式 @Complete_Solution 的行波形式求偏导得：

$
  (partial y)/(partial x) = 1/2 sum_(n=1)^(infinity) lr({ b_n k_n lr([ cos(k_n x + omega_n t) + cos(k_n x - omega_n t) ], size: #200%) }, size: #150%)
$


#abstract(title: [琴弦张力的竖直分量$T_y (x,t)$])[
  $
    T_y (x,t) &= T_0/2 dot sum_(n=1)^(infinity) lr({ b_n k_n lr([ underbrace(cos(k_n x + omega_n t), "左行波") + underbrace(cos(k_n x - omega_n t), "右行波") ], size: #100%) }, size: #110%) #linebreak() &= T_0 dot sum_(n=1)^(infinity) lr({ underbrace(b_n k_n dot cos(k_n x) cos(omega_n t), "驻波形式") }, size: #100%)
  $
]

= 琴弦上的回复力

如弦上波模型的示意图 @Schematic_Diagram_of_wave_on_a_string 所示，琴弦微元段上的回复力：$ F_y & = T_2 sin beta - T_1 sin alpha #linebreak() & = T_x (tan beta - tan alpha) #linebreak() $

将 $T_x$ 近似为静止时的琴弦预张力$T_0$，则：

$
  F_y approx T_0 (partial^2 y)/(partial x^2) Delta x
$

琴弦单位长度上的回复力$f_y$
$ f_y & = F_y / (Delta x) #linebreak() & approx T_0 (partial^2 y)/(partial x^2) $


对等式 @Complete_Solution 的行波形式求偏导得：

$
  (partial y)/(partial x) = 1/2 sum_(n=1)^(infinity) lr({ b_n k_n lr([ cos(k_n x + omega_n t) + cos(k_n x - omega_n t) ], size: #200%) }, size: #150%)
$

继续求二阶偏导得：

$
  (partial^2 y)/(partial x^2) &= - 1/2 sum_(n=1)^(infinity) lr({ b_n k_n^2 lr([ sin(k_n x + omega_n t) + sin(k_n x - omega_n t) ], size: #150%) }, size: #110%) #linebreak() &= - sum_(n=1)^(infinity) lr({ b_n k_n^2 dot sin(k_n x) cos(omega_n t) }, size: #110%)
$


则：

#abstract(title: [琴弦单位长度上的回复力$f_y$])[
  $
    f_y & approx T_0 (partial^2 y)/(partial x^2) #linebreak() & = - T_0 sum_(n=1)^(infinity) lr({ underbrace(b_n k_n^2 dot sin(k_n x) cos(omega_n t), "驻波形式") }, size: #100%) #linebreak() &= - T_0/2 sum_(n=1)^(infinity) lr({ b_n k_n^2 lr([ underbrace(sin(k_n x + omega_n t), "左行波") + underbrace(sin(k_n x - omega_n t), "右行波") ], size: #100%) }, size: #100%)
  $
]


= 弦上波的能量

由初始假设，初始时刻 t=0 时，琴弦的形状为三角形，需要求解此时琴弦上的能量。对微元的能量进行分析：

根据动能的定义： $ Delta K & = 1/2 mu_0 Delta x ( (partial y)/(partial t) )^2 \
        & = mu_0 /2 ( (partial y)/(partial t) )^2 Delta x $

#abstract(title: [质量和弧长的近似])[
  $
    Delta m & approx mu_0 Delta s \
            & approx mu_0 Delta x
  $
  - 将线密度近似为 $mu_0$，即认为振动过程中弦的线密度不发生变化。
  - 将弧长$Delta s$近似为水平距离 $Delta x$。
  我不知道这种近似是否合理，尤其是弧长$Delta s$近似为水平距离$Delta x$的近似是否合理，因为在势能的定义中，$Delta s - Delta x approx 1/2 ((partial y)/(partial x))^2 Delta x$
]

根据势能的定义：

#abstract(title: [势能的定义])[
  - 琴弦在平衡状态（直线）时已经存在预张力 $T_0$ ，取此时的势能为零。
  - 振动的势能来自琴弦被拉伸而产生的额外伸长，即 $Delta s - Delta x$，而非 $Delta s$ 本身。
  - 势能应该是张力 $times$ 伸长量（即弧长减去原长），而不是张力 $times$ 弧长。正确的表达式应为：
]

$
  Delta P & approx T_0 (Delta s - Delta x) \
          & approx T_0 ( sqrt((Delta x)^2 + (Delta y)^2) - Delta x ) \
          & = T_0 inline((sqrt(1 + ((partial y)/(partial x))^2) - 1)) Delta x
$



#abstract(title: [泰勒展开近似])[
  $sqrt(1 + ((partial y)/(partial x))^2) - 1 & = 1/2 ((partial y)/(partial x) )^2 + O( ((partial y)/(partial x) )^4) \
  & approx 1/2 ((partial y)/(partial x) )^2$

  为什么这里选择保留到二阶小量级的近似？
]

则：$ Delta P approx T_0 /2 ((partial y)/(partial x))^2 Delta x $

#abstract(title: [模型近似和误差])[
  动能：
  - 将线密度近似为 $mu_0$
  势能：
  - 将张力近似为 $T_0$
  - 将弧长近似为 $Delta s = sqrt((Delta x)^2 + (Delta y)^2)$

  我不知道这种近似是否合理，与之前波动方程推导中使用的小角度近似是否存在矛盾？
]

总能量 $ E(t) & = integral_0^(L_0) inline((mu_0 /2 ( (partial y)/(partial t) )^2 + T_0 /2 ((partial y)/(partial x))^2 ) d x) $

#question()[
  在$x=x_0$处，$(partial y)/(partial x)$不存在，那么，上面这个等式还是正确的吗？

  答：仍然正确。 黎曼（或勒贝格）积分中，被积函数在有限个孤立点处的值（或不存在）不影响积分值。初始三角波仅在 $x=x_0$ 这一个点处导数不存在，在计算总能量时，积分区间可以避开该点（或理解为该点的贡献为零），因此 E(0) 的积分表达式仍然有效。
]



== 求解 $t=0$ 时刻的能量

由于完整解$y(x,t)$的表达式过于复杂，因此，仅求解$t=0$时刻的总能量，由于不考虑阻尼的近似，总能量$E(t) = E(0)$

因为：$ (partial y)/(partial t) lr(|, size: #200%)_(t=0) = 0 $
$
  (partial y)/(partial x) lr(|, size: #200%)_(t=0) = cases(A_0 / x_0 #h(1.5cm) 0 <= x < x_0, "不存在" #h(1cm) x = x_0, A_0 /(x_0 - L_0) #h(1cm) x_0 < x <= L_0)
$

将这两个等式代入总能量的公式得：$ E(0)
&= integral_0^(x_0) inline(T_0 /2 (A_0^2)/(x_0^2)) d x + integral_(x_0)^(L_0) inline(T_0 /2 (A_0^2)/((L_0 - x_0)^2)) d x \
&= (T_0 A_0^2 L_0)/(2 x_0 (L_0 - x_0)) $

#abstract(title: [初始总能量 $E(0)$ 的物理含义])[

  - 与振幅平方成正比：$E(0) #sym.prop A_0^2$，这是简谐系统（胡克定律型）的典型特征，与弹簧振子、LC 振荡电路等系统的能量形式一致。

  - 与预张力成正比：$E(0) #sym.prop T_0$，张力越大，琴弦越"硬"，在相同初始形变下储存的弹性势能就越大。

  - 拨弦位置 $x_0$ 的影响：分母中出现因子 $x_0 (L_0 - x_0)$，意味着：
    - 当 $x_0 #sym.arrow 0$ 或 $x_0 #sym.arrow L_0$（在端点附近拨弦）时，$E(0) #sym.arrow infinity$，表明要在端点附近将弦拨到指定高度 $A_0$ 需要极大的能量——这符合直觉，因为靠近端点时弦的初始斜率 $A_0 / x_0$ 趋于无穷大。

    - 表达式关于 $x_0 = L_0/2$ 对称，这符合物理对称性：从左侧 $x_0$ 处拨弦与从右侧 $L_0-x_0$ 处拨弦，结果完全相同。

    - 几何意义的验证：从斜率角度理解，$E(0)$ 还可写为：
    $
      E(0) = T_0/2 [ underbrace((A_0/x_0)^2, "左侧斜率平方") dot x_0 + underbrace((A_0/(L_0 - x_0))^2, "右侧斜率平方") dot (L_0 - x_0) ]
    $
    即左右两段弦各自的弹性势能之和，每段势能 = $T_0/2 dot ("斜率")^2 dot "段长"$，几何直观性极强。
]

= 近似

本文在建立弦上波的数学模型时，引入了若干近似。这些近似是数学建模中不可避免的步骤，其目的在于将复杂的真实物理过程简化为可解析求解的数学问题，同时保证在一定条件下模型仍能较好地反映物理本质。下面依次回答相关问题。

== 本文所使用的近似

本文在从真实物理模型到可解数学模型的推导过程中，主要使用了以下近似（按出现顺序）：

+ *小振幅近似*：限定初始振幅满足 $A_0 / L_0 lt.double 1$（例如小于 $1%$）。

+ *小角度近似*：弦上任意位置的斜率 $|(partial y) / (partial x)| lt.double 1$，为后续所有线性化处理奠定基础。

+ *弦长不变近似*：将振动过程中的弦长 $L(t)$ 近似为静止弦长 $L_0$，即忽略由横向振动引起的几何伸长。

+ *张力恒定近似*：将 $T(x,t)$ 近似为静止预张力 $T_0$，认为张力不随局部形变而变化。

+ *线密度恒定近似*：将 $mu(x, t)$ 近似为静止线密度 $mu_0$。

+ *无耗散近似*：忽略空气阻力、内部摩擦、支点能量损失等阻尼效应。

+ *初始形状近似*：将 $t=0$ 时刻的弦形简化为理想的三角形，而非实际拨弦时的光滑曲线。

+ *微元受力分析中的近似*：
  - 忽略微元在 $x$ 方向的加速度，认为张力水平分量 $T_x$ 为恒定值；
  - 进一步将 $T_x$ 近似等于 $T_0$；
  - 在计算张力竖直分量时，将 $cos theta approx 1$。

+ *能量计算中的近似*：
  - 动能表达式中将微元弧长 $Delta s$ 近似为水平距离 $Delta x$；
  - 势能表达式中对 $sqrt(1 + ((partial y) / (partial x))^2) - 1$ 进行泰勒展开，仅保留至二阶小量 $1/2 ((partial y) / (partial x))^2$，忽略 $O(((partial y) / (partial x))^4)$ 及更高阶项。

此外，在实际数值计算中，还隐含了级数截断近似（取有限项 $N_"terms"$ 代替无穷级数）。

== 近似的必要性

真实琴弦振动涉及多重复杂因素：张力随伸长而非线性变化、线密度随形变而改变、空气阻力与内阻尼导致的能量耗散、纵横向耦合振动、材料非均匀性等。这些因素共同作用，使完整的控制方程成为高度非线性的偏微分方程组，通常不存在解析解。

通过上述一系列近似，可将问题简化为经典的线性波动方程

$ (partial^2 y)/(partial x^2) = 1/c^2 (partial^2 y)/(partial t^2) quad (c = sqrt(T_0/mu_0)) $

该方程可通过分离变量法结合傅里叶正弦级数精确求解，得到满足所有边界条件和初始条件的完整解析表达式。因此，近似是获得可解析解的必要代价，也是物理教学与工程分析中广泛采用的合理简化。

== 近似的数学模型在多大程度上符合真实世界中的琴弦振动情况？

判断模型有效性的常用方法包括：

+ *小参数检验*：计算特征小量 $epsilon = A_0/L_0$ 及最大斜率。

+ *实验对比验证*：将模型预测的基频、谐波成分、振动波形以及（若引入阻尼）能量衰减曲线与精密实验测量结果进行定量比较。偏差在工程允许范围内（如频率误差小于 $5%$）即可认为模型有效。

+ *量级分析*：估计被忽略物理效应相对于保留主效应的大小。若被忽略项数量级远小于主效应，则近似合理（如张力相对变化 $(Delta T)/T_0 tilde epsilon^2$ ）。

+ *极限情况检验*：当 $A_0 -> 0$ 时，模型应正确退化为静止直线状态；当阻尼系数趋于零时，总能量应严格守恒。这些极限行为与物理直觉一致，可作为模型自洽性的检验。

+ *数值模拟交叉验证*：用有限元或谱方法求解保留部分非线性效应的完整方程，与本文线性解析解对比，量化偏差随 $epsilon$ 的变化规律。

== 怎样理解和计算这些近似造成的偏差？

近似偏差可从以下几个层面理解和估计：

+ *泰勒展开余项*：势能近似中忽略的 $O(((partial y)/(partial x))^4)$ 项，其相对大小为 $O(epsilon^2)$。因此，当 $epsilon = 0.01$ 时，相对误差约在 $10^(-4)$ 量级，可忽略。

+ *摄动展开法*：引入小参数 $epsilon$，将解写成级数形式 $y = y_0 + epsilon y_1 + epsilon^2 y_2 + dots$，其中 $y_0$ 为本文线性解，$y_1, y_2$ 分别对应非线性修正。通过求解高阶摄动方程可系统计算偏差。

+ *能量守恒偏差*：在线性无阻尼模型中 $E(t) equiv E(0)$。若考虑非线性效应，能量将在基频与高阶谐波间缓慢转移；若考虑阻尼，能量将按指数律衰减。偏差大小可通过比较 $E(t) - E(0)$ 的相对变化来量化。

+ *波形与频谱偏差*：线性模型预测各模态独立振动且频率严格成整数倍关系。真实系统中非线性耦合会导致频谱展宽与频率漂移，偏差可通过实验频谱分析直接观测。

+ *实用估计公式*：对多数工程应用，偏差相对量级可粗估为 $epsilon^2$。当 $epsilon < 0.05$ 时，偏差通常小于 $1%$，可满足教学与初步定量分析需求。

== 经典弦振动模型使用了哪些近似或假设？

经典物理教材（如《振动与波》《理论力学》《波动方程及其应用》）中理想弦振动模型的标准假设与本文完全一致，主要包括：

+ 弦为均匀、各向同性，线密度 $mu_0$ 恒定不变。

+ 振动为纯横向小振幅运动，满足线性化条件 $|(partial y)/(partial x)| << 1$。

+ 张力 $T_0$ 恒定且远大于重力、惯性力等其他外力。

+ 两端固定（或简支、自由等理想边界条件），边界位移始终为零。

+ 无任何形式的外阻尼或内耗散。

+ 初始位移和初始速度为已知确定函数（常取三角波、正弦波或驻波叠加形式）。

本文在此经典框架下，进一步明确了初始三角波近似、能量计算中的泰勒展开近似以及微元分析中的具体简化步骤，使模型更具可操作性。

== 其它必要说明

当实际振幅较大（如拨弦乐器强奏、冲击载荷）或需要精确预测高阶非线性效应时，应放弃线性模型，转而采用包含几何非线性、材料非线性或阻尼项的完整非线性弦振动模型，或直接使用有限元数值方法。本文所建立的线性模型在小振幅、无阻尼条件下具有解析清晰、物理直观、计算简便等优点，特别适合教学演示与初步定量分析。在 $A_0/L_0 < 0.02$ 的典型实验范围内，模型预测与真实物理现象的符合程度通常可达工程精度要求。


= 线性模型与非线性模型的数学界定

在本文的推导与讨论中，多次出现"线性模型"这一术语。为便于读者从数学上准确把握其含义，本章给出线性模型与非线性模型的严格数学定义，并以本文的弦振动模型为例加以说明。

== 线性系统的数学定义

设 $cal(L)$ 是一个将函数空间 $V$ 映射到自身（或另一函数空间 $W$）的算子。称 $cal(L)$ 为*线性算子*，当且仅当对任意 $u, v in V$ 和任意标量 $alpha, beta in RR$，有：

$ cal(L)(alpha u + beta v) = alpha cal(L)(u) + beta cal(L)(v) $ <linear-operator>

这一性质称为*叠加原理*（superposition principle），由齐次性（$cal(L)(alpha u) = alpha cal(L)(u)$）和可加性（$cal(L)(u+v) = cal(L)(u) + cal(L)(v)$）两部分组成。

若描述物理系统演化的控制方程（通常为微分方程或微分方程组）可以写作

$ cal(L)(y) = f $ <governing-eq>

其中 $cal(L)$ 是线性算子，$y$ 是待求函数（如位移场、速度场等），$f$ 是已知源项（外力、初始条件等），则称该系统为*线性系统*，对应的数学模型称为*线性模型*。

线性模型的核心特征包括：

+ 若 $y_1$ 和 $y_2$ 分别是方程 $cal(L)(y_1) = f_1$ 和 $cal(L)(y_2) = f_2$ 的解，则 $y = y_1 + y_2$ 是 $cal(L)(y) = f_1 + f_2$ 的解（叠加原理）。
+ 若 $y$ 是 $cal(L)(y) = f$ 的解，则 $alpha y$ 是 $cal(L)(alpha y) = alpha f$ 的解（齐次性）。
+ 解对初始条件和边界条件具有连续依赖性（适定性），且响应与激励成正比。

== 本文弦振动模型的线性性质

本文所建立的弦上波模型的控制方程为 @Wave_Equation：

$ (partial^2 y)/(partial x^2) = 1/c^2 (partial^2 y)/(partial t^2) $

定义线性波动算子：

$ cal(L)_w (y) := (partial^2 y)/(partial x^2) - 1/c^2 (partial^2 y)/(partial t^2) $

则波动方程可写为 $cal(L)_w (y) = 0$。容易验证：

$ cal(L)_w (alpha y_1 + beta y_2) = alpha cal(L)_w (y_1) + beta cal(L)_w (y_2) $

因此，$cal(L)_w$ 是线性算子，波动方程是线性齐次偏微分方程。该模型的所有解满足叠加原理：若 $y_1$ 和 $y_2$ 分别满足波动方程，则它们的任意线性组合 $alpha y_1 + beta y_2$ 也满足同一方程。

在此基础上，完整的定解问题由波动方程、边界条件和初始条件共同构成：

$
  cases(
    cal(L)_w (y) = 0 #h(1cm) & x in (0, L_0) #h(1cm) t > 0,
    y(0, t) = 0, y(L_0, t) = 0 #h(1cm) & t >= 0,
    y(x, 0) = y_0 (x), (partial y)/(partial t)(x, 0) = 0 #h(1cm) & x in [0, L_0],
  )
$ <linear-IVBP>

其中 $y_0 (x)$ 为初始三角波函数。这是一个线性初边值问题（linear initial-boundary-value problem）。其解 $y(x,t)$ 可表示为傅里叶正弦级数的形式（见 @Complete_Solution），这正是分离变量法与叠加原理直接作用的结果——这正是"线性"一词在该上下文中的核心数学含义。

值得注意的是，@Wave_Equation 中的波速 $c = sqrt(T_0 / mu_0)$ 虽然涉及参数 $T_0$ 和 $mu_0$，但 $c$ 本身是与 $y$ 无关的常数（由近似假设将张力与线密度固定为常量）。因此，$cal(L)_w$ 中的系数 $1/c^2$ 不依赖于 $y$，这是算子线性的关键条件。

== 非线性模型的数学特征

若控制方程中出现的算子 $cal(N)$ 不是线性算子，即存在 $u, v$ 和 $alpha, beta$ 使得

$ cal(N)(alpha u + beta v) != alpha cal(N)(u) + beta cal(N)(v) $

则称该系统为*非线性系统*。在弦振动问题中，常见的非线性来源包括：

+ *几何非线性*：当振幅较大时，弦的伸长不可忽略，张力 $T$ 成为 $y$ 的函数。此时波动方程变为：

$ (partial)/(partial x)(T(x,t) (partial y)/(partial x)) = mu_0 (partial^2 y)/(partial t^2) $

其中 $T(x,t) = T_0 + (E A)/(2 L_0) integral_0^(L_0) ((partial y)/(partial x))^2 d x$ 依赖于 $y$ 的全局斜率平方积分，算子关于 $y$ 不再满足齐次性与可加性。

+ *材料非线性*：弦的本构关系（应力-应变关系）不是线性的（如胡克定律仅在弹性限度内成立）。此时张力与伸长量之间的关系 $T = f((Delta L) / L_0)$ 为非线性函数，$f$ 不可线性化。

+ *阻尼非线性*：阻尼力不与速度成正比，而是与速度的平方或更高次幂成正比，例如 $F_"damp" = - gamma |(partial y)/(partial t)| (partial y)/(partial t)$。

+ *边界非线性*：边界条件本身依赖于待求函数或其导数。例如，若端点并非完全固定，而是受到非线性弹性约束 $y(L_0, t) = k y(L_0, t)^3$，则边界条件成为非线性的。

上述任一非线性因素的引入，都会使叠加原理失效，解不能表示为简单模态的线性组合，从而需要借助摄动方法、数值计算或特殊函数等更复杂的工具进行求解。

== 线性模型与非线性模型的对比总结

设 $cal(L)$ 为线性算子，$cal(N)$ 为非线性算子。两类模型的对比如下：

#table(
  columns: 3,
  inset: 0.6em,
  fill: (_, y) => { if y == 0 { rgb("#79bdc946") } else { none } },
  align: left + horizon,
  table.header([特征], [线性模型 $cal(L)(y) = f$], [非线性模型 $cal(N)(y) = f$]),
  [控制方程形式], [关于 $y$ 及其导数是线性的], [关于 $y$ 或其导数是非线性的],
  [叠加原理], [成立], [不成立],
  [解的可表示性], [可表示为特征函数的无穷级数], [通常无法解析表示],
  [响应与激励关系], [成正比（齐次性）], [不成正比（可能出现跳跃、分岔等）],
  [频率特性], [各模态频率固定且成整数比], [频率随振幅变化，可能产生频谱展宽],
  [适用振幅范围], [$A_0 / L_0 lt.double 1$], [$A_0 / L_0$ 不受限（或受限更弱）],
  [典型求解方法], [分离变量法、傅里叶变换、格林函数], [摄动法、有限元法、数值积分],
)

== 线性模型的近似本质与适用范围

必须强调，本文所讨论的"线性模型"本质上是对真实物理系统的一种*近似*。真实琴弦在严格意义上是非线性系统——张力随伸长变化、线密度随形变改变、空气阻力引入非线性阻尼等因素在物理世界中必然存在。线性模型的建立依赖于本文"模型假设"一节中所列举的一系列近似（小振幅、小角度、张力恒定、线密度恒定、无耗散等）。这些近似的共同效果，是将本来非线性的控制方程简化为线性方程 @Wave_Equation。

线性模型的优势在于：

+ 解析可解性：可通过分离变量法和傅里叶级数获得闭式解析解 @Complete_Solution；
+ 物理直观性：解可分解为独立简正模态的叠加，每个模态对应清晰的物理图像；
+ 计算高效性：级数截断到有限项即可获得足够精确的数值结果。

线性模型的局限性在于：

+ 当 $A_0/L_0$ 超过约 $0.02$ 时，高阶非线性效应不可忽略，线性模型的预测精度显著下降；
+ 无法描述频谱展宽、能量在模态间转移、波形畸变等非线性现象；
+ 在端点附近拨弦时，局部斜率 $(partial y) / (partial x)$ 较大，小角度近似失效，线性模型的误差急剧增大。

因此，本文的线性模型适用于 $A_0/L_0 < 0.02$ 且拨弦位置 $x_"rel"$ 不极端靠近端点的小振幅教学演示与初步定量分析。对于需要高精度预测或涉及大振幅、强非线性效应的工程与科研问题，应使用包含几何非线性、材料非线性或阻尼项的非线性模型，或直接采用有限元方法进行数值模拟。




= 小参数检验与量级分析

本文所建立的弦上波线性模型依赖于小振幅假设 $A_0/L_0 lt.double 1$。本节以文档中定义的默认参数为例，对各近似引入的小参数进行系统检验与量级分析。

== 小参数 $epsilon$ 的定义与典型取值

定义无量纲小参数

$ epsilon = A_0 / L_0 $

代入默认参数：

$ epsilon = 0.01 / 0.6 = 1/60 approx 0.0167 $

该值满足文档中 $A_0/L_0 < 0.02$ 的典型实验要求。

== 最大斜率与倾角的小参数检验

初始三角波的最大斜率为

$ m = max(A_0/x_0, A_0/(L_0 - x_0)) $

对于默认相对拨弦位置 $x_"rel" = 0.1$，有 $x_0 = 0.06$ m，则

$ m = 0.01 / 0.06 approx 0.1667 = 10 epsilon $

对应的最大倾角满足

$ theta_max = arctan(m) approx 0.165 "rad" approx 9.46^degree $

此时

$ cos theta_max approx 0.986 $ 相对偏差约 $1.4%$，这表明小角度近似 $cos theta approx 1$ 的相对误差在可接受范围内（<$2%$）。

当 $x_"rel"$ 趋近于 $0.5$ 时，$m approx 2 epsilon approx 0.033$，$theta_max$ 更小，近似精度显著提高。

从这里也可以看到，当$theta$较小时， $theta approx m$ ，因为：$display(lim_(theta -> 0) ( tan theta )/theta =1)$ ， 即 $theta approx tan theta$ 。

== 势能泰勒展开余项的量级分析

势能近似中使用了泰勒展开

$ sqrt(1 + s^2) - 1 = 1/2 s^2 + R_4(s) $

其中余项满足 $R_4(s) = O(s^4)$，相对误差量级为 $O(s^2)$。

取最不利情况 $s = m = 10 epsilon$，则

$ O(s^2) = O(100 epsilon^2) approx 100 times (0.0167)^2 approx 0.0279 quad (2.8%) $

当拨弦位置接近中点时，$m approx 2 epsilon$，相对误差降至

$ O(4 epsilon^2) approx 0.0011 quad (0.11%) $

因此，对于极端拨弦位置（$x_0 -> 0$ 或 $L_0$），线性模型的势能近似误差与 $epsilon^2$ 同阶且系数较大，需谨慎使用或改用非线性模型。

== 张力模长变化与 $T_x approx T_0$ 的量级检验

由微元受力分析知张力水平分量 $T_x$ 为常数，而实际张力模长

$
  |T| & = T_x / (cos theta) \
      & approx T_x /(1 - 1/2 theta^2 + O(theta^4)) \
      & approx (T_x [1 - 1/2 theta^2 + O(theta^4) + 1/2 theta^2 - O(theta^4)])/(1 - 1/2 theta^2 + O(theta^4)) \
      & approx T_x [1 + O(theta^2)]
$

相对变化量级为

$ ( Delta |T| )/ T_x = O(theta^2) = O(m^2) = O(100 epsilon^2) approx 0.0279 quad (2.8%) $

因此，将 $|T(x,t)| approx T_0$ 的近似相对误差约 $3%$，与小参数 $epsilon$ 的平方同阶。但是当拨弦位置靠近琴弦端点时，系数较大，小角度近似失效。

== 弦长伸长与线密度变化的量级

弦的实际几何伸长量为

$
  Delta L approx integral_0^(L_0) 1/2 ((partial y) / (partial x))^2 d x approx 1/2 m^2 dot (L_0 / 2) = O(epsilon^2 L_0)
$

$
  Delta L approx integral_0^(L_0) 1/2 ((partial y) / (partial x))^2 d x lt 1/2 m^2 dot L_0 = O(100 epsilon^2 L_0)
$

相对伸长

$ (Delta L) / L_0 = O(100 epsilon^2) approx 0.028 #h(0.5cm) (2.8%) $

线密度相对变化同样为 $O(epsilon^2)$ 量级。但是当拨弦位置靠近琴弦端点时，系数较大，小角度近似失效。


在本文模型中，由于假设预张力远大于由伸长引起的张力增量，故可将 $mu(x, t) approx mu_0$ 和 $L(t) approx L_0$。


== 波速、周期与频率的量级

波速

$ c = sqrt(T_0 / mu_0) = sqrt(80 / 0.01) = sqrt(8000) approx 89.44 "m/s" $

基频与周期

$ f_1 = c / (2 L_0) approx 89.44 / 1.2 approx 74.53 "Hz" $

$ T_1 = 1/f_1 approx 0.0134 "s" $

在默认参数下，一个周期内波传播距离约 $c T_1 = 1.2 "m"$，恰好为 $2 L_0$，与驻波节点结构一致。

== 结论

通过以上系统的小参数检验与量级分析，本文模型在默认参数下各近似相对误差均控制在 $1% ~ 3%$ 量级，满足工程精度与教学演示要求。当满足

$ epsilon < 0.01 quad "且" quad x_"rel" in [0.2, 0.8] $

时，最大斜率 $m < 5 epsilon$，各近似相对误差可进一步降低至 $0.5%$ 以下。若需更高精度，应引入非线性修正或采用有限元数值方法。



= 由级数截断引起的完整解$y(x,t)$的绝对误差

在$y(x,t)$的实际数值计算中，无法对无穷级数求和，只能取有限项 $N$ 作为近似。本节从完整解 $y(x,t)$ 出发，系统推导截断误差的表达式并估计其相对量级。

== 截断误差的定义

记完整解（无穷级数）为 $y(x,t)$，截断到 $N$ 项的近似解为 $y_N (x,t)$：

$
  y_N (x,t) = sum_(n=1)^(N) b_n sin(k_n x) cos(omega_n t)
$

则截断误差为被截断的尾部级数：

$
  E_N (x,t) & = y(x,t) - y_N (x,t) \
            & = sum_(n=N+1)^(infinity) b_n sin(k_n x) cos(omega_n t)
$

== 绝对误差上界估计

由于对任意 $x$ 和 $t$ 有 $|sin(k_n x) cos(omega_n t)| <= 1$，可得点态误差的保守上界:

$
  |E_N (x,t)| <= sum_(n=N+1)^(infinity) |b_n|
$

由前文推导的傅里叶系数公式：

$
  b_n = (2 A_0 L_0^2)/(x_0(L_0 - x_0) pi^2 n^2) sin(k_n x_0)
$

取绝对值并利用 $|sin(k_n x_0)| <= 1$，得到：

$
  |b_n| <= (2 A_0 L_0^2)/(x_0(L_0 - x_0) pi^2) dot 1/n^2 equiv C / n^2
$

其中常数 $C$ 定义为：

$
  C = (2 A_0 L_0^2)/(x_0(L_0 - x_0) pi^2)
$

因此点态误差满足：

$
  |E_N (x,t)| <= C sum_(n=N+1)^(infinity) 1/n^2
$

利用积分近似估计级数尾部（对单调递减函数 $1/x^2$，有 $integral_(N+1)^infinity 1/x^2 d x < sum_(n=N+1)^infinity 1/n^2 < integral_N^infinity 1/x^2 d x$），取更保守的上界：

$
  sum_(n=N+1)^(infinity) 1/n^2 < integral_N^infinity 1/x^2 d x = 1/N
$

代入得绝对误差上界：

$
  |E_N (x,t)| <= C/N
$



== 保守上界的保守性来源详解

上述绝对误差上界 $epsilon_N <= C/N$ 的推导串联使用了三项保守近似，每一项都会使理论界高于实际误差。理解这些保守性的来源，有助于正确解读误差估计结果，避免对模型精度产生不必要的担忧。

=== 保守来源一：$|sin(k_n x_0)| <= 1$

系数 $b_n$ 的严格表达式包含振荡因子 $sin(k_n x_0) = sin(n pi x_"rel")$。将其绝对值上界取为 $1$，意味着丢弃了该正弦因子随 $n$ 振荡的全部信息——这些振荡会使大量项的贡献远小于 $|b_n|$ 的上界。

以默认参数 $x_"rel" = 0.1$ 为例，尾部区间 $n > N = 50$ 中 $sin(k_n x_0) = sin(0.1 pi n)$ 的取值呈现周期为 $20$ 的模式：

#table(
  columns: 3,
  inset: 0.6em,
  fill: (_, y) => { if y == 0 { rgb("#79bdc946") } else { none } },
  align: center + horizon,
  [$n$], [$0.1 pi n$], [$sin(0.1 pi n)$],
  [$51$], [$5.1 pi$], [$-0.309$],
  [$55$], [$5.5 pi$], [$-1$],
  [$60$], [$6 pi$], [$0$],
  [$65$], [$6.5 pi$], [$1$],
  [$70$], [$7 pi$], [$0$],
)

取默认参数$x_"rel"=0.1$时，在尾部区间中，每 $20$ 项里只有 $2$ 项取到 $|sin| = 1$，$2$ 项严格为零，其余 $16$ 项介于 $0$ 与 $1$ 之间。对于充分大的 $N$，$|sin(k_n x_0)|$ 在尾部区间上的渐近均值为 $2/pi approx 0.637$。这意味着仅此一项保守近似，就使 $|b_n|$ 的上界被系统性地高估了约 $1/0.637 - 1 approx 57%$。

#abstract(title: [$sin(k x)$在正半区间上的均值])[
  $display(< sin(k x) > & = (integral_0^(pi/k) sin (k x) d x) / (pi / k) \ & = k / pi * (- 1 / k) lr([cos (k x)], size: #200%)_0^(pi/k) \ &= 2/pi)$
]

更极端的情形是 $x_"rel" = 0.5$（中点拨弦），此时 $x_0 = L_0/2$，故 $k_n x_0 = n pi / 2$

$ sin(k_n x_0) = sin(n pi / 2) = cases(0 #h(2cm) "当" n "为偶数", (-1)^((n-1)/2) #h(1cm) "当" n "为奇数") $

即 $b_n$ 对所有偶数 $n$ 严格为零。尾部区间 $n > N = 50$ 中 $sin(k_n x_0)$ 的取值呈现周期为 $4$ 的严格交替模式：

#table(
  columns: 3,
  inset: 0.6em,
  fill: (_, y) => { if y == 0 { rgb("#79bdc946") } else { none } },
  align: center + horizon,
  [$n$], [$n pi / 2$], [$sin(n pi / 2)$],
  [$51$], [$51 pi / 2$], [$-1$],
  [$52$], [$26 pi$], [$0$],
  [$53$], [$53 pi / 2$], [$1$],
  [$54$], [$27 pi$], [$0$],
  [$55$], [$55 pi / 2$], [$-1$],
  [$56$], [$28 pi$], [$0$],
  [$57$], [$57 pi / 2$], [$1$],
  [$58$], [$29 pi$], [$0$],
  [$59$], [$59 pi / 2$], [$-1$],
  [$60$], [$30 pi$], [$0$],
)

由此可对截断误差做更精确的估计。记 $N = 50$，尾部级数中只有奇数 $n$ 的项非零：

$
  |E_N (x,t)| <= sum_(n=N+1)^infinity |b_n| = (2 A_0 L_0^2)/(x_0(L_0 - x_0) pi^2) sum_(n=N+1, n "为奇数")^infinity 1/n^2
$

令 $M = floor(N/2) = 25$，将奇数指标 $n = 2m - 1$ 代入，$m = (n + 1)/ 2$ 取26到$+ infinity$， 尾部求和转化为：

$
  sum_(n=N+1, n "为奇数")^infinity 1/n^2 & = sum_(m=M+1)^infinity 1/((2m - 1)^2) \
                                         & < integral_M^infinity (d x)/((2x - 1)^2) \
                                         & = - 1/4 * 1/(x - 1/2) lr(|, size: #200%)_M^(infinity) \
                                         & = 1/(2(2M - 1)) \
                                         & approx 1/(4M) \
                                         & approx 1/(2N)
$

代入得：

$ |E_N (x,t)| < (2 A_0 L_0^2)/(x_0(L_0 - x_0) pi^2) dot 1/(2N) $

与保守上界 $C/N$ 对比（其中 $C = (2 A_0 L_0^2)/(x_0(L_0 - x_0) pi^2)$），可知尾部实际有效求和项数减半，导致截断误差上界再缩小约一倍。此即所谓"有效截断项数翻倍"的精确含义：

- 定义 *有效截断项数* $N_"eff"$ 为使不等式 $|E_N (x,t)| <= C / N_"eff"$ 成立的 $N_"eff"$，$N$ 为实际保留的级数项数。
- 当 $x_"rel" = 0.5$ 时，$N_"eff" = 2N$，即误差上界与 $N'$ 取 $2N$ 时的保守上界相当。
- 当 $x_"rel" = 0.1$ 时，$|sin(k_n x_0)|$ 在尾部以均值 $2/pi$ 振荡，$N_"eff" approx pi/2 N approx 1.57 N$，介于 $N$ 与 $2N$ 之间。

此外，$x_"rel" = 0.5$ 时 $x_0(L_0 - x_0) = L_0^2/4$ 取最大值，使得常数 $C$ 本身也达到最小值。两项因素共同作用，使中点拨弦的截断误差远小于端点附近拨弦的情形。



=== 保守来源二：$|sin(k_n x) cos(omega_n t)| <= 1$

完整解中第 $n$ 个模态在时空点 $(x,t)$ 处的瞬时贡献为 $b_n sin(k_n x) cos(omega_n t)$。在绝对误差上界的推导中，我们用 $|sin(k_n x) cos(omega_n t)| <= 1$ 替代实际值。这等价于假设：在任意时空点 $(x,t)$，所有被截断模态的三角函数因子都取最大可能振幅 $1$，且符号完全对齐。然而，这一假设包含三层不可同时满足的理想化条件：

+ *振幅条件（跨模态同步条件）*：$|sin(k_n x) cos(omega_n t)| = 1$ 要求 $|sin(k_n x)| = 1$ 且 $|cos(omega_n t)| = 1$ 同时成立，即空间因子和时间因子同时达到极值。这要求 $k_n x = pi/2 + m pi$ 且 $omega_n t = l pi$，在固定的 $(x,t)$ 下无法对多个 $n$ 同时满足。

+ *符号对齐条件*：即使部分模态的振幅接近 $1$，其符号（正负号）也可能相互抵消。实际级数求和 $sum b_n sin(k_n x) cos(omega_n t)$ 中存在大量正负项抵消，而上界 $sum |b_n|$ 完全忽略了这种抵消效应。

==== 定量分析：单个模态的均方根值

*RMS 的基本概念*：均方根（Root Mean Square，简称 RMS）是统计学和信号分析中用于衡量一组数值或一个函数"典型大小"的常用指标，尤其适合描述正负交替的振荡量。其计算步骤依次为：

+ *平方（Square）*：对每个取值求平方，消除正负号的影响，使所有贡献变为正值；
+ *平均（Mean）*：计算所有平方值的平均值（对于连续函数，则在一定的定义域内积分求平均）；
+ *开根（Root）*：对平均值开平方，使结果量纲恢复为原函数的量纲。

对于定义在区间 $[a, b]$ 上的连续函数 $f(x)$，其 RMS 值的一般定义为：

$
  f_"RMS" = sqrt(1/(b-a) integral_a^b [f(x)]^2 d x)
$

对于离散数据点 $x_1, x_2, dots, x_N$，RMS 定义为：

$
  x_"RMS" = sqrt(1/N sum_(i=1)^N x_i^2)
$

*角括号 $⟨·⟩$ 的数学含义*：在本文语境中，角括号 $⟨·⟩$ 表示函数在某个域上的*平均值*（mean），即 $⟨ f ⟩ = 1/("域长") integral_("域") f d("变量")$。具体而言：

- $⟨ sin^2(k_n x) ⟩$ 表示 $sin^2(k_n x)$ 在空间 $x in [0, L_0]$（或一个完整空间周期 $[0, pi/k_n]$）上的平均值；
- $⟨ cos^2(omega_n t) ⟩$ 表示 $cos^2(omega_n t)$ 在长时间尺度（或一个完整时间周期 $[0, pi/omega_n]$）上的平均值。

对于周期函数而言，在一个完整周期上求平均等价于在长时间尺度上求平均。

*为什么 $⟨ sin^2 theta ⟩ = 1/2$？* 利用三角恒等式 $sin^2 theta = (1 - cos(2 theta))/2$，在 $theta$ 的一个完整周期 $[0, pi]$ 上求平均：

$
  ⟨ sin^2 theta ⟩ = 1/pi integral_0^(pi) sin^2 theta d theta = 1/pi integral_0^(pi) (1 - cos(2 theta))/2 d theta = 1/2
$

由于 $cos(2 theta)$ 在一个完整周期上的积分为零，因此结果恰好为 $1/2$。同理可证 $⟨ cos^2 theta ⟩ = 1/2$。

*乘积平均的独立性分解*：注意到 $sin(k_n x)$ 仅依赖于空间变量 $x$，$cos(omega_n t)$ 仅依赖于时间变量 $t$，且 $x$ 与 $t$ 是相互独立的变量。因此，乘积的平均可以分解为各自平均的乘积：

$
  ⟨ sin^2(k_n x) cos^2(omega_n t) ⟩ = ⟨ sin^2(k_n x) ⟩ dot ⟨ cos^2(omega_n t) ⟩
$

*具体计算*：综合以上结论，对单个模态的三角函数因子计算 RMS：

$
  text("RMS") = sqrt(⟨ sin^2(k_n x) cos^2(omega_n t) ⟩) = sqrt(⟨ sin^2(k_n x) ⟩ dot ⟨ cos^2(omega_n t) ⟩) = sqrt(1/2 times 1/2) = 1/2
$

其中角括号 $⟨·⟩$ 表示在 $x$ 或 $t$ 上的平均。这意味着，单个模态的三角函数因子的典型贡献幅度仅为 $1/2$，而非上界 $1$。仅此一项就使 $|b_n|$ 的贡献被高估了约 $1$ 倍（即估计值为实际值的约 $2$ 倍）。

==== 定量分析：不同模态的正负抵消

将三角函数重写为行波形式：

$
  sin(k_n x) cos(omega_n t) = 1/2 [sin(k_n x + omega_n t) + sin(k_n x - omega_n t)]
$

在固定的 $(x,t)$ 处，不同 $n$ 对应的正弦函数 $sin(k_n x plus.minus omega_n t)$ 的相位 $(k_n x plus.minus omega_n t) = n pi (x/L_0 plus.minus c t/L_0)$ 随 $n$ 线性递增。不同 $n$ 的相位差使得这些项在大量求和时发生正负抵消，类似于满足狄利克雷条件的傅里叶级数在有限项截断后的尾部振荡。

==== 定量分析：数值示例

以默认参数 $L_0 = 0.6 m$, $x_"rel" = 0.1$, $T_0 = 80 N$, $mu_0 = 0.01 "kg"\/m$ 为例，考虑尾部区间 $n = 51$ 到 $60$ 的十个模态在 $x = 0.2 m$ 处、$t = 0.005$ s时 的实际贡献与保守上界的对比：

#{
  // 文档默认参数（与文档定义的默认值保持一致）
  let L0 = 0.6
  let x_rel = 0.1
  let x_0 = x_rel * L0
  let x = 0.2
  let t = 0.005
  let T0 = 80
  let mu0 = 0.01
  let c = calc.sqrt(T0 / mu0)

  // 计算 sin(k_n x) cos(omega_n t)
  let sin_cos(n) = {
    let kn = n * calc.pi / L0
    let omegan = c * kn
    calc.sin(kn * x) * calc.cos(omegan * t)
  }

  let v51 = sin_cos(51)
  let v52 = sin_cos(52)
  let v53 = sin_cos(53)
  let v54 = sin_cos(54)
  let v55 = sin_cos(55)
  let v56 = sin_cos(56)
  let v57 = sin_cos(57)
  let v58 = sin_cos(58)
  let v59 = sin_cos(59)
  let v60 = sin_cos(60)

  // 四舍五入到 3 位小数
  let r3(v) = calc.round(v * 1000) / 1000

  // 构造显示内容（若舍入后为零则显式显示 0.000）
  let disp(v) = {
    let r = r3(v)
    if r == 0.0 { [$0.000$] } else { [$#r$] }
  }

  let sum = r3(v51 + v52 + v53 + v54 + v55 + v56 + v57 + v58 + v59 + v60)
  let sum_abs = r3(
    calc.abs(v51)
      + calc.abs(v52)
      + calc.abs(v53)
      + calc.abs(v54)
      + calc.abs(v55)
      + calc.abs(v56)
      + calc.abs(v57)
      + calc.abs(v58)
      + calc.abs(v59)
      + calc.abs(v60),
  )

  table(
    columns: 4,
    inset: 0.6em,
    fill: (_, y) => { if y == 0 { rgb("#79bdc946") } else { none } },
    align: center + horizon,
    [$n$], [$sin(k_n x) cos(omega_n t)$], [$|sin(k_n x) cos(omega_n t)|$], [保守取值],
    [$51$], disp(v51), disp(calc.abs(v51)), [$1$],
    [$52$], disp(v52), disp(calc.abs(v52)), [$1$],
    [$53$], disp(v53), disp(calc.abs(v53)), [$1$],
    [$54$], disp(v54), disp(calc.abs(v54)), [$1$],
    [$55$], disp(v55), disp(calc.abs(v55)), [$1$],
    [$56$], disp(v56), disp(calc.abs(v56)), [$1$],
    [$57$], disp(v57), disp(calc.abs(v57)), [$1$],
    [$58$], disp(v58), disp(calc.abs(v58)), [$1$],
    [$59$], disp(v59), disp(calc.abs(v59)), [$1$],
    [$60$], disp(v60), disp(calc.abs(v60)), [$1$],
    [求和], disp(sum), disp(sum_abs), [$10$],
  )
}


十个模态（$n = 51$ 至 $60$）的保守取值之和为 $10$。在 $x = 0.2$ m、$t = 0.005$ s 处，$sin(k_n x) cos(omega_n t)$ 的实际代数和仅为 $0.13$，绝对值之和为 $3.61$。这意味着：

- 实际代数和降至保守上界的约 $1.3%$（$0.13/10$），主要得益于不同符号导致的部分抵消；
- 绝对值之和约占保守上界的 $36.1%$（$3.61/10$），反映了即使消除符号抵消效应，各模态的三角函数因子仍远未达到最大值 $1$。

这一数值示例直观表明：用 $|sin(k_n x) cos(omega_n t)| <= 1$ 替代实际值会导致对截断误差的严重高估。高估程度取决于所采用的衡量标准：
- 若以实际代数和为基准，高估因子约为 $10/0.13 approx 77$ 倍——符号抵消效应被完全归入高估；
- 若以实际绝对值之和为基准（仅保留 RMS 与极值之间的差距），高估因子约为 $10/3.61 approx 2.77$ 倍；
- 若以单个模态的 RMS 均值 $1/2$ 为基准（从统计意义上消除跨模态同步与符号抵消的双重高估），高估因子约为 $2$ 倍。

==== 综合估计

综合以上分析，保守来源二对误差上界的高估是三个因素中最为严重的，且具有显著的 $(x,t)$ 依赖性：
- 在波腹附近且时间恰逢各模态同相时，高估程度较小，接近 RMS 层面的 $2$ 倍；
- 在波节附近或时间恰逢各模态反相时，实际代数和趋于零而保守上界保持不变，高估因子理论上趋于无穷大。

这一特性使得保守来源二在大部分时空点上的高估程度远超保守来源一（约 $1.57$ 倍）和保守来源三（约 $1.005$ 倍），但其严重性随位置和时间剧烈波动，而非如保守来源一那样具有均匀、系统性的特征。




=== 保守来源三：积分上界 $sum_(n=N+1)^infinity 1/n^2 < 1/N$

利用积分比较法将级数尾部上界取为 $1/N$ 是一种标准估计技巧：

$ sum_(n=N+1)^infinity 1/n^2 < integral_N^infinity 1/x^2 d x = 1/N $

实际上，该积分上界略高于真实级数尾部。使用 Euler-Maclaurin 公式可以得到更精确的渐近展开：

$ sum_(n=N+1)^infinity 1/n^2 = 1/N - 1/(2 N^2) + O(1/N^3) $

代入 $N = 50$：
- 保守上界 $1/N = 0.02000$
- 更精确的值 $sum_(n=51)^infinity 1/n^2 approx 0.01990$
- 相对高估：仅约 $0.5%$

可见该项的保守性最弱，对误差上界的高估几乎可以忽略不计。之所以仍然保留这一近似，是因为它形式简洁，便于解析推导。

=== 三种保守性的对比与综合

将三个保守来源并列对比：

#table(
  columns: 3,
  inset: 0.6em,
  fill: (_, y) => { if y == 0 { rgb("#79bdc946") } else { none } },
  align: center + horizon,
  [保守来源], [导致高估的程度], [性质],
  [$|sin(k_n x_0)| <= 1$], [约 $57%$（均值高估）], [系统性的、与 $N$ 无关],
  [$|sin(k_n x) cos(omega_n t)| <= 1$], [约 $2$ 倍（RMS 层面），正负抵消可加剧], [随 $(x,t)$ 波动、统计性],
  [积分上界 $1/N$], [约 $0.5%$（可忽略）], [系统性的、随 $N$ 增大而减小],
)

三个因素相互独立，联合效应近似为乘积关系。综合估算，实际误差 $|E_N (x,t)|$ 的典型值约为保守上界 $C/N$ 的 $1/4$ 至 $1/2$（在考虑了 RMS 和正负抵消的更精确分析下，典型情形约 $1/3$，优于此前 $1/2$ 的粗略估计）。在更有利的条件下（如 $x_"rel"$ 接近 $0.5$、$t$ 恰逢多个模态过零的时刻），实际误差可降低至上界的 $1/10$ 甚至更低。

这一分析说明：归一化绝对误差的保守上界 $4.5%$ 虽然在数学上严格成立，但其取值明显高于典型情况；实际应用中约 $1%$ 至 $2%$ 的归一化误差估计更为合理，与基础小参数 $epsilon approx 1.67%$ 处于同一量级，体现了整个模型各近似环节之间误差控制的一致性。




= 由级数截断引起的完整解$y(x,t)$的相对误差

== 相对误差定义

在数值分析中，近似解 $y_N$ 相对于真解 $y$ 的*点态相对误差*严格定义为：

$
  e_N^text("strict")(x,t) = (|E_N (x,t)|) / (|y(x,t)|), quad
  epsilon_N^text("strict") = max_(x in [0, L_0], t >= 0) e_N^text("strict")(x,t)
$

但在本问题中直接采用此定义存在两个困难：

+ 真解 $y(x,t)$ 本身以无穷级数形式给出，其逐点精确值 $|y(x,t)|$ 在解析上无法闭合表达，更难求出全局最大值；
+ 在弦的波节附近（$y(x,t) approx 0$），分母 $|y(x,t)|$ 趋于零。此时分子 $|E_N(x,t)|$ 通常不为零（除非在两端点 $x=0, L_0$ 处所有 $sin(k_n x)=0$），因此 $e_N^text("strict")$ 在波节附近可能趋于无穷大——即使截断精度在整体上已足够，点态相对误差也会因分母过小而失去数学意义，不适合用作误差度量。

因此，本文采用初始最大振幅 $A_0$ 替代 $|y(x,t)|$ 作为归一化参考，定义*归一化绝对误差上界*：

$
  epsilon_N & = max_(x in [0, L_0], t >= 0) (|E_N (x,t)|) / A_0 \
            & <= C/(N A_0) \
            & = (2 L_0^2)/(x_0(L_0 - x_0) pi^2 N)
$

== 数值估算

由前节绝对误差分析知，归一化绝对误差上界满足：

$
  epsilon_N <= (2 L_0^2)/(x_0(L_0 - x_0) pi^2 N)
$

代入默认参数 $L_0 = 0.6 "m"$, $x_"rel" = 0.1$, $N_"terms" = 50$ 得保守上界 $epsilon_N <= 4.5%$。

如前节保守性分析所述，此上界包含三重保守近似：
- $|sin(k_n x_0)| <= 1$ 导致 $b_n$ 的模被系统性高估约 $57%$；
- $|sin(k_n x) cos(omega_n t)| <= 1$ 导致各模态贡献在 RMS 意义上被高估约 $1$ 倍（即估计值为实际值的约 $2$ 倍）；
- 积分上界 $1/N$ 的误差仅约 $0.5%$，可忽略。

三者的联合效应近似为乘积关系。综合考虑，实际归一化误差的典型值约为保守上界的 $1/4$ 至 $1/2$，即约 $1%$ 至 $2%$，与基础小参数 $epsilon = A_0/L_0 approx 1.67%$ 处于同一量级。

== 拨弦位置对截断误差的影响

从 $epsilon_N$ 的表达式可以看出，分母中包含因子 $x_0(L_0 - x_0)$：

- 当 $x_0 -> 0$ 或 $x_0 -> L_0$（端点附近拨弦）时，分母趋于零，$epsilon_N -> infinity$——端点附近拨弦激发出更多高阶谐波分量，需要大幅增加截断项数才能保证精度；
- 当 $x_0 = L_0/2$（中点拨弦）时，$epsilon_N$ 取最小值。不仅如此，此时 $sin(k_n x_0) = sin((n pi)/2)$ 对所有偶数 $n$ 严格为零，级数中仅剩奇数项，实际有效项数再减半，截断误差进一步减小。


== 该定义的合理性与参考价值

采用 $A_0$ 归一的合理性建立在以下数学事实上：

+ *位移有界性*：在线性无阻尼模型中，由能量守恒可知 $|y(x,t)| <= A_0$ 对任意 $(x,t)$ 成立。因此：

$
  e_N^text("strict")(x,t) = (|E_N (x,t)|) / (|y(x,t)|) gt.eq (|E_N (x,t)|) / (max |y(x,t)|) gt.eq (|E_N (x,t)|) / (A_0)
$

即 $A_0$ 归一化误差是严格相对误差的一个*保守下界*——若归一化误差在可接受范围内，则严格相对误差可能更大，需注意这一差异。

+ *在最大位移处等价*：在 $|y(x,t)| approx A_0$ 的区域（如 $t=0$ 时刻的波峰附近），两者趋于一致。

+ *工程可操作性*：$A_0$ 是已知的输入参数，而 $max |y(x,t)|$ 是未知的求解目标。用已知量归一化使得误差估计可以先于完整求解进行。

综上，本文定义的 $epsilon_N$ 虽然不是严格数学意义上的相对误差，但在工程与数值分析中是合理且常用的替代度量，其数值提供了对截断精度的可靠保守估计。

= 什么是归一化误差

== 误差的基本分类

在数值计算与科学工程中，误差分析是衡量计算结果可信度的核心环节。按度量方式的不同，误差通常分为以下三类：

#table(
  columns: 3,
  inset: 0.6em,
  fill: (_, y) => { if y == 0 { rgb("#79bdc946") } else { none } },
  align: center + horizon,
  table.header([误差类型], [定义], [特点]),
  [绝对误差], [$E = |y - hat(y)|$], [量纲与原始数据相同，无法跨问题比较],
  [相对误差], [$e = ( |y - hat(y)| ) / (|y|)$], [无量纲，可跨问题比较，但分母为零时无意义],
  [归一化误差], [$epsilon = (|y - hat(y)|) / (Y_("ref"))$], [无量纲，用固定参考值 $Y_("ref")$ 替代分母 $|y|$],
)

其中，$y$ 表示精确值（或参考真值），$hat(y)$ 表示近似值或计算值。

== 相对误差的局限性

相对误差 $e = ( |y - hat(y)| ) / (|y|)$ 在理论上是最自然的无量纲误差度量，但在实际使用中面临两个突出问题：

+ *分母过零问题*：当精确值 $y approx 0$ 时，相对误差趋于无穷大，即使近似解 $hat(y)$ 的绝对误差已经足够小。例如，在弦振动问题的波节附近，$y(x,t) approx 0$，此时相对误差完全失去参考意义，无法用于评估近似解的质量。

+ *参考值未知问题*：在许多实际问题中，精确值 $y$ 本身就是求解的目标，在计算之前并不知道。如果必须依赖 $y$ 才能定义误差，则误差分析无法先于求解进行，陷入了"先有答案才能评价答案"的逻辑循环。

== 归一化误差的定义

归一化误差（normalized error）正是为克服相对误差的上述局限性而引入的替代度量。其一般定义为：

$
  epsilon = (|y - hat(y)|) / (Y_("ref"))
$

其中 $Y_("ref") > 0$ 是一个预先选定的、不依赖具体求解点 $(x,t)$ 的固定参考值。与相对误差的关键区别在于：分母不再是被求函数本身的瞬时值 $|y(x,t)|$，而是一个全局常数。因此：

- 归一化误差**不会因分母过零而发散**，在整个定义域内都有明确的数学意义；
- 归一化误差**可以在求解之前预先估计**，因为 $Y_("ref")$ 通常取自已知的物理参数或输入条件。

== 归一化参考值的常见选取方式

根据具体问题的特点，$Y_("ref")$ 可以有多种合理的选取方式：

#table(
  columns: 3,
  inset: 0.6em,
  fill: (_, y) => { if y == 0 { rgb("#79bdc946") } else { none } },
  align: left + horizon,
  table.header([参考值 $Y_("ref")$], [典型选取], [适用场景]),
  [输入幅值], [初始位移 $A_0$、激励幅值等], [振动、波动、振荡系统],
  [量程范围], [仪表的满量程值], [测量仪器与传感器],
  [特征尺度], [几何尺寸 $L_0$、特征速度 $c$ 等], [流体力学、传热学中的无量纲化],
  [统计量], [均值、标准差、最大值], [数据拟合与统计分析],
)

== 归一化误差与相对误差的关系

归一化误差与真正（严格）的相对误差之间存在如下不等式关系：

$
  epsilon = (|y - hat(y)|) / (Y_("ref")) <= (|y - hat(y)|) / (max |y|) <= (|y - hat(y)|) / (|y|) = e
$

特别地，当取 $Y_("ref") = A_0 = max |y|$（即初始振幅等于位移最大值）时，第一个不等号成为等号：

$
  epsilon = (|y - hat(y)|) / (A_0) = (|y - hat(y)|) / (max |y|) <= (|y - hat(y)|) / (|y|) = e
$

即归一化误差 $epsilon$ 是严格相对误差 $e$ 的一个**下界**（$epsilon <= e$ 恒成立）。这意味着：

- 若归一化误差已经很小，严格相对误差**可能更大**（但归一化误差至多与严格相对误差一样大）；
- 在分母 $|y|$ 很小的区域（如波节附近），严格相对误差可能远大于归一化误差，因此归一化误差不能完全替代相对误差在非波节区域的严格性检验。



== 本文中归一化误差的具体形式

在前文级数截断误差的分析中，本文采用了如下形式的归一化误差：

$
  epsilon_N = max_(x in [0, L_0], t >= 0) (|E_N (x,t)|) / A_0
$

其中：

- $E_N (x,t) = y(x,t) - y_N (x,t)$ 为级数截断的绝对误差；
- $A_0$ 为初始最大振幅，是已知的输入参数；
- $epsilon_N$ 的物理含义是：截断误差不超过初始最大振幅的 $epsilon_N times 100%$。

== 归一化误差的优势总结

+ *物理意义直观*：$epsilon_N$ 直接告诉使用者"近似解的误差最多占初始振幅的百分之几"，无需关心具体时空位置。
+ *数学性质良好*：不会因分母过零而发散，在整个定义域 $[0, L_0] times [0, infinity)$ 上有定义且有限。
+ *先验可估*：其保守上界 $epsilon_N <= (2 L_0^2)/(x_0(L_0 - x_0) pi^2 N)$ 仅由已知参数 $(L_0, x_0, N)$ 决定，可以在完整求解之前对截断精度做出预判。
+ *与相对误差互补*：在振幅较大的区域（波腹附近）两者趋于一致；在振幅较小的区域（波节附近）归一化误差替代失效的相对误差，填补了误差度量的空白。

综上，归一化误差是连接绝对误差与相对误差的桥梁，它在保留无量纲优势的同时，克服了相对误差的分母过零缺陷，是科学计算与工程分析中不可或缺的误差度量工具。

= 小参数检验方法

本文在多个章节中使用了"小参数检验"这一概念，但其在原文中仅作为模型有效性判断的一个要点被简要列出，并未展开论述其方法与原理。小参数检验（small-parameter test）是应用数学与工程分析中用于验证模型近似合理性的重要工具。其核心思想是：如果模型的控制方程或解中包含某个无量纲小参数 $epsilon$，且该参数的值远小于 $1$，则可据此对模型进行简化（如忽略 $O(epsilon^2)$ 及更高阶的小量），从而获得可解析处理或易于数值计算的近似模型。本章对这一方法进行系统性的数学阐述。

== 小参数的定义与数学本质

=== 小参数的一般定义

设某一物理系统由控制方程 $cal(E)(y; p_1, p_2, dots, p_k) = 0$ 描述，其中 $y$ 是待求函数（如位移、温度、速度场等），$p_1, p_2, dots, p_k$ 是系统的物理参数（具有各自的量纲）。若通过某种方式从这些参数中构造出一个无量纲量

$ epsilon = f(p_1, p_2, dots, p_k) in RR^+ $

且满足 $0 < epsilon lt.double 1$（通常要求 $epsilon <= 0.1$ 甚至 $epsilon <= 0.01$），则称 $epsilon$ 为该系统的*小参数*（small parameter）。

小参数的本质是将具有量纲的物理参数之间的相对大小关系，转化为一个无量纲的数值比较。这种转化使得"大小"的判断不再依赖于单位制的选择，具有客观性和普适性。

=== 量纲分析的必要性

在构造小参数之前，必须对系统的全部物理参数进行量纲分析（dimensional analysis）。量纲分析的核心结果是 Buckingham $pi$ 定理：

设某一物理过程涉及 $m$ 个具有量纲的物理参数 $q_1, q_2, dots, q_m$，其中基本量纲的个数为 $r$（在经典力学中通常为 $r=3$：长度、时间、质量），则存在 $m - r$ 个独立的无量纲 $pi$ 数 $pi_1, pi_2, dots, pi_(m - r)$，使得原始物理关系等价于这些 $pi$ 数之间的函数关系：

$ F(pi_1, pi_2, dots, pi_(m - r)) = 0 $

在无量纲 $pi$ 数中，若某个 $pi_j$ 的数值远小于 $1$，则它就是一个潜在的小参数，可作为后续近似分析的依据。

=== 小参数与无量纲化的关系

小参数的构造通常伴随着控制方程的无量纲化过程。设原始控制方程涉及具有量纲的变量 $x$（空间坐标）、$t$（时间）和参数 $p_1, p_2, dots, p_k$。引入特征尺度：

$ tilde(x) = x/ L_0, quad tilde(t) = t/ tau_0 , quad tilde(y) = y/ A_0 $

其中 $L_0, tau_0, A_0$ 分别是长度、时间和振幅的特征尺度。则原始控制方程可转化为关于无量纲变量 $tilde(x), tilde(t), tilde(y)$ 的方程，其中各项系数均为无量纲参数的组合。这些无量纲参数中，数值远小于 $1$ 者即为小参数。

== 小参数的选取原则

小参数的选取不是任意的，应遵循以下数学原则：

+ *量纲独立性*：小参数必须是无量纲的。具有量纲的量不能作为小参数，因为其数值大小依赖于单位制的选择（例如，$1$ cm 在 SI 制下为 $0.01$，在 mm 制下为 $10$）。

+ *物理意义明确*：小参数应能直观反映被忽略物理效应与保留主效应之间的相对大小。例如在弦振动模型中：

$ epsilon = A_0 / L_0 $

其物理含义是初始最大横向位移与弦长之比，直接反映了"小振幅"假设的合理程度。

+ *渐近完备性*：当 $epsilon arrow 0$ 时，简化模型应严格退化为某个已知的极限情形（零阶近似）。这一性质是摄动展开的出发点。

+ *敏感性可量化*：物理量 $Q$ 对 $epsilon$ 的依赖关系应可用泰勒级数或渐近级数展开，即存在 $Q(epsilon) = Q_0 + epsilon Q_1 + epsilon^2 Q_2 + dots$，使得 $Q_0$ 对应 $epsilon = 0$ 的极限情形，$Q_1, Q_2, dots$ 为各阶修正。

== 小参数检验的数学框架

小参数检验可形式化为以下三个步骤。

=== 第一步：无量纲化与小参数识别

以本文的弦振动模型为例。控制方程为：

$ (partial^2 y)/(partial x^2) = 1/c^2 (partial^2 y)/(partial t^2), quad c = sqrt(T_0 / mu_0) $

边界条件：$y(0,t) = y(L_0, t) = 0$

初始条件：

$
  y(x,0) = cases(A_0/x_0 x #h(2.5cm) 0 <= x <= x_0, A_0/(L_0 - x_0)(L_0 - x) #h(1cm) x_0 < x <= L_0) #h(2cm) (partial y(x,t))/(partial t) = 0
$

引入无量纲变量：

$ tilde(x) = x / L_0, quad tilde(y) = y / A_0, quad tilde(t) = t / tau_0, quad tau_0 = L_0 / c $

则波动方程化为无量纲形式：

$ (partial^2 tilde(y))/(partial tilde(x)^2) = (partial^2 tilde(y))/(partial tilde(t)^2) $

边界条件化为：

$ tilde(y)(0, tilde(t)) = tilde(y)(1, tilde(t)) = 0 $

初始条件化为：

$
  tilde(y)(tilde(x), 0) = cases(1 / tilde(x)_0 * tilde(x) #h(1cm) &0 <= tilde(x) <= tilde(x)_0, 1 / (1 - tilde(x)_0) * (1 - tilde(x)) #h(1cm) &tilde(x)_0 < tilde(x) <= 1)
$

其中 $tilde(x)_0 = x_0 / L_0 = x_"rel"$ 为无量纲拨弦位置。在这个无量纲化过程中，$epsilon = A_0 / L_0$ 并未出现在控制方程中（因 $y$ 已被 $A_0$ 归一化），但它隐含在原始物理量恢复公式 $tilde(y) = y/ A_0$ 中，决定了线性化近似的量级。

=== 第二步：量级估计

对偏微分方程中的各项进行量级估计。设 $y = O(A_0)$，$x = O(L_0)$，$t = O(tau_0)$，则：

$ (partial y)/(partial x) = O(A_0 / L_0) = O(epsilon), quad (partial^2 y)/(partial x^2) = O(epsilon / L_0) $

$ (partial y)/(partial t) = O(A_0 / tau_0), quad (partial^2 y)/(partial t^2) = O(A_0 / tau_0^2) $

对于张力模长的相对变化：

$ (|T|) / T_0 - 1 = O(epsilon^2) $

对于势能近似中泰勒展开的余项：

$ sqrt(1 + ((partial y)/(partial x))^2) - 1 = 1/2 ((partial y)/(partial x))^2 + O(epsilon^4) $

这些量级估计为近似模型的误差分析提供了定量依据。

=== 第三步：小参数展开与模型简化

定义小参数展开（small-parameter expansion），亦称渐近展开（asymptotic expansion）：

$ y(x,t) = y_0 (x,t) + epsilon y_1 (x,t) + epsilon^2 y_2 (x,t) + dots $

代入原始控制方程，按 $epsilon$ 的同次幂整理，可得一系列递推的线性方程（摄动方程）：

$ cal(L)(y_0) = 0 quad text("零阶近似（主导项）") $

$ cal(L)(y_1) = cal(N)_1 (y_0) quad text("一阶修正") $

$ cal(L)(y_2) = cal(N)_2 (y_0, y_1) quad text("二阶修正") $

其中 $cal(L)$ 是线性算子，$cal(N)_1, cal(N)_2$ 是由非线性项产生的源项（依赖于低阶解）。

若仅保留零阶项 $y_0$，则得到线性化模型。若需更高精度，可依次求解各阶修正项 $y_1, y_2, dots$。这种系统化的近似方法称为*摄动方法*（perturbation method）。

== 小参数检验的一般步骤

综合以上分析，小参数检验可归纳为以下标准步骤：

#table(
  columns: 3,
  inset: 0.6em,
  fill: (_, y) => { if y == 0 { rgb("#79bdc946") } else { none } },
  align: left + horizon,
  table.header([步骤], [操作内容], [数学表达]),
  [1. 参数梳理], [列出系统的全部物理参数及其量纲], [$p_1, p_2, dots, p_k$],
  [2. 无量纲化], [引入特征尺度，构造无量纲变量], [$tilde(x) = x / L_0, tilde(t) = t / tau_0, tilde(y) = y / A_0$],
  [3. 小参数识别], [从无量纲参数中找出数值远小于 $1$ 者], [$epsilon = A_0 / L_0 lt.double 1$],
  [4. 量级估计], [估计被忽略项与保留项的相对量级], [$O(epsilon^2), O(epsilon^4), dots$],
  [5. 展开与简化], [将解按 $epsilon$ 幂次展开，截断到所需阶数], [$y = y_0 + epsilon y_1 + epsilon^2 y_2 + dots$],
  [6. 误差验证], [计算截断误差或与数值解对比], [$|y - y_0| = O(epsilon)$],
)

== 小参数检验与摄动理论的关系

小参数检验与摄动理论（perturbation theory）关系密切，但二者并非同一概念：

- *小参数检验*是一个更宽泛的方法论概念，涵盖了从参数识别、量纲分析、量级估计到近似合理性判断的全过程。其核心目的是*检验*某一近似是否合理，而非*求解*近似解。
- *摄动理论*则是小参数检验在求解层面的具体实现——当确认存在小参数后，摄动方法提供了一套系统化的数学工具（正则摄动、奇异摄动、多尺度方法等），用于构造 $epsilon$ 的渐近展开解。

二者的关系可以概括为：小参数检验回答"能不能近似"的问题，摄动理论回答"如何近似"的问题。在本文中，小参数检验主要用于验证线性化假设的合理性，而完整的 $y(x,t)$ 级数解则是摄动方法（在零阶截断意义下）的结果。

== 小参数 <epsilon> 与本模型各近似的关系总览

本文所使用的各个近似均可在小参数 $epsilon$ 的框架下统一理解。下表总结了各近似对应的量级与误差控制情况：

#table(
  columns: 4,
  inset: 0.6em,
  fill: (_, y) => { if y == 0 { rgb("#79bdc946") } else { none } },
  align: left + horizon,
  table.header([近似类型], [小参数表达], [相对量级], [默认参数下的典型值]),
  [小振幅近似], [$epsilon = A_0 / L_0$], [$epsilon$], [$1.67%$],
  [小角度近似], [$m = max|(partial y)/(partial x)|$], [$O(epsilon)$ 至 $O(10 epsilon)$], [$3.3%$ 至 $16.7%$],
  [张力恒定近似], [$(Delta |T|) / T_0$], [$O(epsilon^2)$ 至 $O(100 epsilon^2)$], [$0.03%$ 至 $2.8%$],
  [弦长恒定近似], [$(Delta L) / L_0$], [$O(epsilon^2)$ 至 $O(100 epsilon^2)$], [$0.03%$ 至 $2.8%$],
  [势能泰勒展开], [忽略 $O(s^4)$], [$O(4 epsilon^2)$ 至 $O(100 epsilon^4)$], [$0.11%$ 至 $2.8%$],
  [级数截断近似], [取前 $N$ 项], [$O(1/N)$], [取 $N=50$ 时约 $1%$ 至 $2%$],
)

从表中可以看出：
- 所有近似的相对误差均可表示为 $epsilon$ 的幂次（$epsilon^k$）乘以一个系数，该系数依赖于拨弦位置 $x_"rel"$ 等几何参数；
- 当拨弦位置靠近端点（$x_"rel" arrow 0$ 或 $x_"rel" arrow 1$）时，系数急剧增大，小角度近似可能失效；
- 当拨弦位置靠近中点（$x_"rel" approx 0.5$）时，系数取最小值，各近似的精度显著提高。

== 小参数检验的局限性

小参数检验作为一种近似合理性判断工具，本身也存在局限性：

+ *小参数的选取不唯一*：同一系统可能存在多种构造小参数的方式。例如，在弦振动问题中，除 $epsilon = A_0/L_0$ 外，还可定义 $delta = max|(partial y)/(partial x)|$ 作为小参数。不同的选取方式可能导致不同的简化策略和不同的近似精度。

+ *小参数"小"的标准不统一*：$epsilon$ 的值需要小到什么程度才能保证近似有效，取决于问题对精度的要求。在工程应用中，$5%$ 的误差通常可接受，但在精密测量中可能需要 $0.1%$ 以下。因此，$epsilon lt.double 1$ 只是一个定性要求，定量判断需要结合具体问题的误差容限。

+ *存在小参数并不意味着线性化总是成立*：某些系统即使 $epsilon$ 很小，也可能因系统本身的非线性本质（如混沌系统）而无法用线性模型有效近似。小参数检验只能确保量级上的合理性，不能替代对系统动力学行为的全面分析。

+ *奇异摄动问题*：在某些情况下，直接令 $epsilon arrow 0$ 会导致控制方程的类型发生根本性变化（如微分方程降阶），使得边界条件无法全部满足。此类问题属于奇异摄动范畴，不能简单应用本章所述的正则小参数检验方法，需引入边界层分析、多尺度方法等更复杂的工具。

+ *多参数问题*：实际系统常涉及多个无量纲参数（如 Reynolds 数、Mach 数、Prandtl 数等），这些参数可能同时具有不同的量级。此时需要在参数空间中识别主导小参数，并考虑参数之间的耦合效应，单一小参数的检验框架可能不足以刻画系统的全部近似结构。

== 小结

本章从数学角度系统介绍了小参数检验方法。该方法的核心是通过量纲分析构造无量纲小参数 $epsilon$，然后利用 $epsilon lt.double 1$ 这一事实，对控制方程或物理量进行量级估计、渐近展开和模型简化。小参数检验与摄动理论既有联系又有区别：前者是近似合理性的验证工具，后者是近似解的系统构造方法。在实际应用中，二者通常结合使用，共同构成从物理模型到可解数学模型之间的桥梁。

在本文的弦振动模型中，$epsilon = A_0/L_0$ 是最基本的小参数，所有近似的相对误差均可量化为 $epsilon$ 的幂次与几何相关因子的乘积。$epsilon approx 1.67%$ 的默认取值确保了各近似环节的一致性，使得线性化模型在小振幅条件下具有良好的工程精度。

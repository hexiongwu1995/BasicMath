
// 辅助函数定义
#let title-page(title, author, date) = {
  align(center)[
    #v(5cm)
    #set text(size: 20pt, weight: "bold")
    #title
    #set text(size: 12pt)
    #v(1em)
    #author
    #v(1em)

    #date.display("[year]-[month]-[day]")
  ]
  pagebreak()
}


#let table-of-contents() = {
  outline(depth: 2, indent: auto)
  pagebreak()
}

// 模板主函数定义（核心）
#let conf(
  // 文档元数据参数
  title: "文档标题",
  author: "作者姓名",
  date: datetime.today(),
  // 其他自定义参数...
  body,
) = {
  // 文档全局设置

  set page(
    paper: "a4",
    margin: 1.5cm,
    numbering: "1/1",
    number-align: center,
    fill: rgb("#ffffff13"),
  )

  show title: it => {
    set align(center)
    set text(size: 18pt, weight: "bold", fill: rgb("#0066fff0"))
    it
    v(1em)
  }

  set par(spacing: 2em, leading: 1em, justify: true)

  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    v(1em)
    set text(size: 15pt, weight: "bold", fill: rgb("#0066fff0"))
    it
    v(1em)
  }

  show heading.where(level: 2): it => {
    v(0.5em)
    set text(size: 12pt, weight: "bold", fill: rgb("#0066fff0"))
    it
    v(0.5em)
  }

  show heading.where(level: 3): it => {
    v(0.5em)
    set text(size: 10pt, weight: "bold", fill: rgb("#0066fff0"))
    it
    v(0.5em)
  }

  set text(
    lang: "zh",
    font: (
      "Cambria Math",
      "KaiTi",
      "DengXian",
      "New Computer Modern Sans",
      "Noto Sans Mono CJK SC",
      "SimSun",
      "Segoe UI Emoji",
    ),
    size: 10pt,
  )

  show table: it => {
    set align(center)
    it
  }

  set math.equation(numbering: n => numbering("(1.1)", counter(heading).get().first(), n), supplement: [Eq.])

  show math.equation: set block(breakable: true)


  // 封面 / 前置部分
  title-page(title, author, date) // 自定义封面函数


  // 目录
  table-of-contents()

  // 正文内容（必须置于最后）
  body
}









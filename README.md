# Workflow

单向工作流, 没有异步操作 🌝

只是用来处理在同一个 func 中，有多条内容不完全重复时，需要不断定义新的变量名的解决方案

没错，只是用来减少变量名的定义而出现的这个库 ！！！🧐


# 使用说明

Workflow 开始，然后 then 可以无限衔接，可在任意块中修改返回值给下一个 then 使用,

使用 end 或 done 结束~

```swift
try Workflow {
    [1, 2, 3]
}.then { value in   // value is [Int] 
    $0.map { "\($0)" }
}.end { value in   // value is [String]
    print(value)
}
```

也可以使用 value 获取结束前任意阶段的结果

```swift
let intArray = try Workflow {
    [1, 2, 3]
}.value

print(intArray)
```

# 支持 Concurrency

```swift
try await Workflow {
    try await URLSession.shared.data(for: URLRequest)
}.then { pair in 
    pair.0 // Data
    pair.1 // Response
}
```

## 安装

```swift
// swift 5.0
.package(url: "https://github.com/iWECon/Workflow", .upToNextMajor(from: "1.0.0"))
```

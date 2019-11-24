## `union-find`算法探究

### 一、动态连通性
> 若两个变量p和q为连通的，则需要满足以下性质:
- 自反性：p和p是相连的
- 对称性：如果p和q是相连的，则q和p也是相连的
- 传递性：如果p和r是相连的，r和q是相连的，则p和q也是相连的

### 二、`quick-find`算法

![quick-find算法的API](https://user-gold-cdn.xitu.io/2019/11/24/16e9d5159f50208b?w=702&h=151&f=png&s=25325)

> 如果两个触点在不同的分量，`union()`操作会将两个分量归并。`find()`操作会返回给定触点所对应的连通分量的标识符。`connected()`操作能够判断两个触点是否存在同一个分量中。`count()`方法会返回所有连通分量的数量。一开始会有N个分量，将两个分量归并的每次`union()`操作都会使分量总数减一。

```swift
class QuickFind {
    
    private var ids: [Int]
    private var components: Int
    
    init(_ N: Int) {
        components = N
        ids = Array.init(repeating: 0, count: N)
        for i in 0 ..< N {
            ids[i] = i
        }
    }
    
    public func count() -> Int {
        return components
    }
    
    public func find(_ p: Int) -> Int {
        return ids[p]
    }
    
    public func connected(p: Int, q: Int) -> Bool {
        return find(p) == find(q)
    }
    
    public func union(p: Int, q: Int) {
        let pId = find(p)
        let qId = find(q)
        
        if pId == qId {
            return
        }
        
        for i in 0 ..< ids.count {
            if ids[i] == pId {
                ids[i] = qId
            }
        }
        
        components -= 1
    }
}
```

> `quick-find`算法的性能问题主要在于对每一对输入`union()`都需要扫描整个`ids[]`数组。每调用一次`union()`操作访问数组的次数在`N+3`和`2N+1`之间。最坏的情况是当只存在一个连通分量时，意味着至少需要调用`N-1`次`union`操作，那么至少需要`(N+3)(N-1)~N2`次访问数组。

### 三、`quick-union`算法
> 为了提高`union()`方法的速度，需要对索引数组`ids[]`进行优化，将其值赋值为同一分量中的另一个触点的名称（也可能是它自己本身）。通过这种方式，将同一分量中的触点构成一条“链接”。那么就可以通过查找两个触点中的“根触点”来判断两者是否在同一分量中。

![](https://user-gold-cdn.xitu.io/2019/11/24/16e9d7299e6e23c5?w=394&h=513&f=png&s=77606)

```swift
public func find(_ p: Int) -> Int {
    var p = p
    while p != ids[p] { //不断往上追溯，直到为根触点
        p = ids[p]
    }
    return p
}

public func union(p: Int, q: Int) {
    let pRoot = find(p)
    let qRoot = find(q)
    
    if pRoot == qRoot {
        return
    }
    
    ids[pRoot] = qRoot //将两个根触点合并
    
    components -= 1
}
```
> 虽然`quick-uinon`算法对比起`quick-find`算法，解决了`union()`操作性能问题，但在`find()`操作中依旧存在性能问题。假设输入的序列为有序的`0-1,0-2,0-3`等，那么最终所得到的树的高度为`N-1`。对于整数对`0-i, union()`操作访问数组的次数为`2i+1`，那么处理`N`对整数所需的`find()`操作访问数组的总次数为`3+5+6+...+(2N-1)~N2`。

![](https://user-gold-cdn.xitu.io/2019/11/24/16e9d7db1356a0f2?w=509&h=513&f=png&s=55298)

### 四、加权`quick-union`算法
> 与其在`union()`中随意将一棵树连接到另一棵树，我们修改为记录每一棵树的大小并总是将较小的树连接到较大的树上，从而避免树的深度多大。

![](https://user-gold-cdn.xitu.io/2019/11/24/16e9d804626c0bb3?w=553&h=396&f=png&s=74160)

```swift
class WeightQuickUnion {
    
    private var ids: [Int]
    private var szs:[Int] //用于记录每一颗树的大小
    private var components: Int
    
    init(_ N: Int) {
        components = N
        ids = Array.init(repeating: 0, count: N)
        for i in 0 ..< N {
            ids[i] = i
        }
        szs = Array.init(repeating: 1, count: N)
    }
    
    public func count() -> Int {
        return components
    }
    
    public func find(_ p: Int) -> Int {
        var p = p
        while p != ids[p] {
            p = ids[p]
        }
        return p
    }
    
    public func connected(p: Int, q: Int) -> Bool {
        return find(p) == find(q)
    }
    
    public func union(p: Int, q: Int) {
        let i = find(p)
        let j = find(q)
        
        if i == j {
            return
        }
        
        if szs[i] < szs[j] { //判断树的大小，总是将较小的树添加到较大的树种
            ids[i] = j
            szs[j] += szs[i]
        } else {
            ids[j] = i
            szs[i] += szs[j]
        }
        
        components -= 1
    }
}
```
![](https://user-gold-cdn.xitu.io/2019/11/24/16e9d8657a8e7012?w=666&h=492&f=png&s=123877)

> 通过加权的方式，将森林的深度降低。**对于N个触点，所构造的森林中的任何节点的深度最多为`lgN`**。
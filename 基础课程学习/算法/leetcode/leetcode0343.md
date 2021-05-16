https://leetcode-cn.com/problems/integer-break/

```go
func integerBreak(n int) int {
	cache := make([]int, n+1) //忽略第0个位置的值
	cache[1] = 1
	cache[2] = 1
	if n == 2 {
		return cache[n]
	}

	for i := 3; i <= n; i++ {
		m := 0
		for j := 1; j <= i-1; j++ {
			temp := cache[j] * cache[i-j]
			if temp > m {
				m = temp
			}
			temp = j * (i - j)
			if temp > m {
				m = temp
			}
			temp = cache[j] * (i - j)
			if temp > m {
				m = temp
			}
			temp = j * cache[i-j]
			if temp > m {
				m = temp
			}
		}
		cache[i] = m
	}
	return cache[n]
}
```

测试

```go
func main() {
	for i := 2; i <= 55; i++ {
		fmt.Println(i, integerBreak(i))
	}
}
```
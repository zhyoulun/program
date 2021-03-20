https://leetcode-cn.com/problems/perfect-squares/

```go
func numSquares(n int) int {
	intMax := int(^uint(0) >> 1)
	squareDict := make(map[int]int, 101)
	for i := 0; i <= 100; i++ {
		squareDict[i*i] = i
	}
	if n == 1 {
		return 1
	} else if n == 2 {
		return 2
	}
	cache := make([]int, n+1)
	cache[1] = 1
	cache[2] = 2
	for i := 3; i <= n; i++ {
		if _, exist := squareDict[i]; exist {
			cache[i] = 1
			continue
		}
		m := intMax
		for j := 1; j < i; j++ {
			temp := cache[j] + cache[i-j]
			if temp < m {
				m = temp
			}
		}
		cache[i] = m
	}
	return cache[n]
}
```

```go
func main() {
	for i := 1; i <= 13; i++ {
		fmt.Println(i, numSquares(i))
	}
}
```
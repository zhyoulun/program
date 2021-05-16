https://leetcode-cn.com/problems/count-primes/

### 判断一个数是否为质数

```go
func isPrime(n int) bool {
	if n == 1 || n == 2 {
		return true
	}
	for i := 2; i <= n-1; i++ {
		if n%i == 0 {
			return false
		}
	}
	return true
}
```

```go
func isPrime(n int) bool {
	if n == 1 || n == 2 {
		return true
	}
	for i := 2; i <= int(math.Sqrt(float64(n))); i++ {
		if n%i == 0 {
			return false
		}
	}
	return true
}
```

还有更快的方法

https://blog.csdn.net/afei__/article/details/80638460

### 题目

暴力写法，容易超时

```go
func countPrimes(n int) int {
	if n < 2 {
		return 0
	}
	total := 0
	for i := 2; i < n; i++ {
		if isPrime(i) {
			total++
		}
	}
	return total
}
```

埃氏筛

如果 xx 是质数，那么大于 xx 的 xx 的倍数 2x,3x,...一定不是质数，因此我们可以从这里入手。

```go
func countPrimes(n int) int {
	nums := make([]int, n)
	for i := 0; i < n; i++ {
		nums[i] = 1
	}
	result := 0
	for i := 2; i < n; i++ {
		if nums[i] == 1 {
			result++
			for j := 2; j*i < n; j++ {
				nums[j*i] = 0
			}
		}
	}
	return result
}
```
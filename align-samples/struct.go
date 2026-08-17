// Try: select the struct fields, `ga` then `\s` (space) or use `ga` then enter a space

package main

type ServerConfig struct {
Host string
Port int
Timeout time.Duration
MaxRetries int
EnableTLS bool
CertFile string
}

type DBConfig struct {
DSN string
MaxOpenConns int
MaxIdleConns int
ConnLifetime time.Duration
}

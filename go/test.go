package main

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
)

func main() {
	casbinDB, err := sql.Open("mysql", "root:root@tcp(127.0.0.1:3306)/")
	sqlQuery := fmt.Sprintf("select password from casbin.user where name='wujiang'")
	rows, err := casbinDB.Query(sqlQuery)
	fmt.Println(rows, err)
}

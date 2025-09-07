package dbsrc

import (
	"database/sql"
	"log"
	"os"

	_ "github.com/lib/pq"
	loggersrc "github.com/roscherk/se_2025_calculator/logger_src"
)

type DbHandler struct {
	curDb     *sql.DB
	curLogger loggersrc.ILogger
}

func (curDbHandler DbHandler) Close() {
	curDbHandler.curDb.Close()
	curDbHandler.curLogger.Log("Db is closed")
}

func (curDbHandler DbHandler) DoQueryRow(query string, args ...any) *sql.Row {
	return curDbHandler.curDb.QueryRow(query, args...)
}

func (curDbHandler DbHandler) DoQuery(query string, args ...any) (*sql.Rows, error) {
	return curDbHandler.curDb.Query(query, args...)
}

func (curDbHandler DbHandler) DoExec(query string, args ...any) (sql.Result, error) {
	return curDbHandler.curDb.Exec(query, args...)
}

func (curDbHandler DbHandler) createTables() {
	_, err := curDbHandler.curDb.Exec(`
    CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY
    )
`)
	if err != nil {
		curDbHandler.curLogger.Log(err.Error())
		log.Fatal(err)
	}

	_, err = curDbHandler.curDb.Exec(`
    CREATE TABLE IF NOT EXISTS history (
        id INT NOT NULL,
		expression TEXT NOT NULL
    )
`)
	if err != nil {
		curDbHandler.curLogger.Log(err.Error())
		log.Fatal(err)
	}

	curDbHandler.curLogger.Log("Tables created successfully")
}

func InitDb(curLogger loggersrc.ILogger) *DbHandler {
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		curLogger.Log("DATABASE_URL environment variable is required")
		log.Fatal("DATABASE_URL environment variable is required")
	}

	db, err := sql.Open("postgres", databaseURL)
	if err != nil {
		curLogger.Log(err.Error())
		log.Fatal(err)
	}

	err = db.Ping()
	if err != nil {
		curLogger.Log(err.Error())
		log.Fatal(err)
	}
	curLogger.Log("Successfully connected to PostgreSQL")

	curDbHandler := DbHandler{db, curLogger}
	curDbHandler.createTables()

	return &curDbHandler
}

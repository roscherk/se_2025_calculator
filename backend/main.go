package main

import (
	"fmt"

	"github.com/gofiber/fiber/v2"
	dbsrc "github.com/roscherk/se_2025_calculator/db_src"
	_ "github.com/roscherk/se_2025_calculator/docs"
	loggersrc "github.com/roscherk/se_2025_calculator/logger_src"
	serversrc "github.com/roscherk/se_2025_calculator/server_src"
)

const port = 8000

// @title Calculator API
// @version 1.0
// @description API для математических вычислений
// @host localhost:8000
// @BasePath /
func main() {
	app := fiber.New()

	curLogger := loggersrc.BaseLogger{}

	curDB := dbsrc.InitDb(curLogger)
	defer curDB.Close()
	serversrc.SetupSwagger(&app, port, curLogger)
	serversrc.SetupRoutes(&app, curLogger, curDB)

	curLogger.Log("Server is starting")
	app.Listen(fmt.Sprintf(":%d", port))
}

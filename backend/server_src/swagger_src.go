package serversrc

import (
	"fmt"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/swagger"
	_ "github.com/roscherk/se_2025_calculator/docs"
	loggersrc "github.com/roscherk/se_2025_calculator/logger_src"
)

func SetupSwagger(app **fiber.App, port int, logger loggersrc.Logger) {
	(*app).Get("/swagger/*", swagger.New(swagger.Config{
		URL:         fmt.Sprintf("http://localhost:%d/swagger/doc.json", port),
		DeepLinking: true,
		Title:       "Calculator API Documentation",
	}))
	logger.Log(fmt.Sprintf("Swagger set up on port %d", port))
	logger.Log(fmt.Sprintf("Swagger UI: http://localhost:%d/swagger/", port))
	logger.Log(fmt.Sprintf("Swagger JSON: http://localhost:%d/swagger/doc.json", port))
}

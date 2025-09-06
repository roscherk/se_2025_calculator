package serversrc

import (
	"github.com/gofiber/fiber/v2"
	_ "github.com/roscherk/se_2025_calculator/docs"
	loggersrc "github.com/roscherk/se_2025_calculator/logger_src"
)

func SetupRoutes(app **fiber.App, curLogger loggersrc.Logger) {
	curRoutesHandler := RoutesHandler{curLogger}
	(*app).Get("/register", curRoutesHandler.registerUser)
	(*app).Post("/calculate", curRoutesHandler.calculateExpression)
	(*app).Get("/history", curRoutesHandler.getHistory)
}

type RoutesHandler struct {
	Logger loggersrc.Logger
}

// @Summary Зарегестрировать новое устройство
// @Router /register [get]
func (curRoutesHandler RoutesHandler) registerUser(c *fiber.Ctx) error {
	return c.SendStatus(200)
}

// @Summary Получить историю
// @Router /history [get]
func (curRoutesHandler RoutesHandler) getHistory(c *fiber.Ctx) error {
	return c.SendStatus(200)
}

// @Summary Посчитать выражение
// @Router /calculate [post]
func (curRoutesHandler RoutesHandler) calculateExpression(c *fiber.Ctx) error {
	return c.SendStatus(200)
}

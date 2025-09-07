package serversrc

import (
	"fmt"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/roscherk/se_2025_calculator/calculator"
	dbsrc "github.com/roscherk/se_2025_calculator/db_src"
	_ "github.com/roscherk/se_2025_calculator/docs"
	loggersrc "github.com/roscherk/se_2025_calculator/logger_src"
)

func SetupRoutes(app **fiber.App, curLogger loggersrc.ILogger, curDb *dbsrc.DbHandler) {
	curRoutesHandler := RoutesHandler{curLogger, curDb}
	(*app).Get("/register", curRoutesHandler.registerUser)
	(*app).Post("/calculate", curRoutesHandler.calculateExpression)
	(*app).Get("/history/:id", curRoutesHandler.getHistory)
}

type RoutesHandler struct {
	Logger loggersrc.ILogger
	CurDb  *dbsrc.DbHandler
}

type Response struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// @Summary Зарегестрировать новое устройство
// @Router /register [get]
func (curRoutesHandler RoutesHandler) registerUser(c *fiber.Ctx) error {

	curRoutesHandler.Logger.Log(fmt.Sprintf("Trying register user"))
	var userID int
	err := curRoutesHandler.CurDb.DoQueryRow("INSERT INTO users DEFAULT VALUES RETURNING id").Scan(&userID)

	if err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusBadRequest).JSON(Response{
			Success: false,
			Error:   err.Error(),
		})
	}
	curRoutesHandler.Logger.Log(fmt.Sprintf("Successfully registered user: %v", userID))
	return c.Status(fiber.StatusOK).JSON(Response{
		Success: true,
		Data:    userID,
	})
}

// @Summary Получить историю
// @Router /history [get]
func (curRoutesHandler RoutesHandler) getHistory(c *fiber.Ctx) error {
	curRoutesHandler.Logger.Log(fmt.Sprintf("Trying sending history"))
	tmpid := c.Params("id")
	id, err := strconv.Atoi(tmpid)

	if err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusBadRequest).JSON(Response{
			Success: false,
			Error:   "ID must be a number",
		})
	}
	curRoutesHandler.Logger.Log(fmt.Sprintf("Successfully found history of user: %v", id))
	rows, err := curRoutesHandler.CurDb.DoQuery("SELECT expression FROM history WHERE id = $1", id)
	if err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusInternalServerError).JSON(Response{
			Success: false,
			Error:   "DB error: " + err.Error(),
		})
	}

	defer rows.Close()

	curRoutesHandler.Logger.Log("Starting collecting info from DB")
	//collecting data for DB
	var historyMas []string
	for rows.Next() {
		var curExpression string
		if err := rows.Scan(&curExpression); err != nil {
			curRoutesHandler.Logger.Log(err.Error())
			return c.Status(fiber.StatusInternalServerError).JSON(Response{
				Success: false,
				Error:   "Data parsing error: " + err.Error(),
			})
		}
		historyMas = append(historyMas, curExpression)
	}

	if err := rows.Err(); err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusInternalServerError).JSON(Response{
			Success: false,
			Error:   "Rows iteration error",
		})
	}
	curRoutesHandler.Logger.Log(fmt.Sprintf("Sending history to user user: %v", id))
	return c.JSON(Response{
		Success: true,
		Data:    historyMas,
	})
}

type CalculationRequest struct {
	UserID     int
	Expression string
}

// @Summary Посчитать выражение
// @Router /calculate [post]
func (curRoutesHandler RoutesHandler) calculateExpression(c *fiber.Ctx) error {
	curRoutesHandler.Logger.Log("Starting reading expression")

	var req CalculationRequest
	if err := c.BodyParser(&req); err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusBadRequest).JSON(Response{
			Success: false,
			Error:   "Invalid JSON format: " + err.Error(),
		})
	}

	curRoutesHandler.Logger.Log(fmt.Sprintf("Trying to calculate expression: %s \nFrom user: %v", req.Expression, req.UserID))
	ansOfExpression, err := calculator.Evaluate(req.Expression)
	if err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusBadRequest).JSON(Response{
			Success: false,
			Error:   err.Error(),
		})
	}
	exprValue := fmt.Sprintf("%s=%f", req.Expression, ansOfExpression)
	_, err = curRoutesHandler.CurDb.DoExec("INSERT INTO history (id, expression) VALUES ($1, $2)", req.UserID, exprValue)

	if err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusInternalServerError).JSON(Response{
			Success: false,
			Error:   "DB error: " + err.Error(),
		})
	}
	return c.Status(fiber.StatusOK).JSON(Response{
		Success: true,
	})
}

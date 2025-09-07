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

type ErrorResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

type RegisterResponse struct {
	Success bool   `json:"success"`
	Data    int    `json:"data,omitempty"`
	Error   string `json:"error,omitempty"`
}

func (curRoutesHandler RoutesHandler) isUserRegistrated(id int) (bool, error) {
	var count int
	err := curRoutesHandler.CurDb.DoQueryRow("SELECT id FROM users WHERE id = $1", id).Scan(&count)

	if err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return false, err
	}
	return count > 0, nil
}

// @Summary Зарегистрировать новое устройство
// @Description Создает нового пользователя и возвращает его ID
// @Tags users
// @Produce json
// @Success 200 {object} RegisterResponse
// @Failure 400 {object} ErrorResponse
// @Router /register [get]
func (curRoutesHandler RoutesHandler) registerUser(c *fiber.Ctx) error {

	curRoutesHandler.Logger.Log("Trying register user")
	var userID int
	err := curRoutesHandler.CurDb.DoQueryRow("INSERT INTO users DEFAULT VALUES RETURNING id").Scan(&userID)

	if err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{
			Success: false,
			Error:   err.Error(),
		})
	}
	curRoutesHandler.Logger.Log(fmt.Sprintf("Successfully registered user: %v", userID))
	return c.Status(fiber.StatusOK).JSON(RegisterResponse{
		Success: true,
		Data:    userID,
	})
}

type HistoryResponse struct {
	Success bool     `json:"success"`
	Data    []string `json:"data"`
	Error   string   `json:"error,omitempty"`
}

// @Summary Получить историю вычислений
// @Description Возвращает историю вычислений для указанного пользователя
// @Tags history
// @Produce json
// @Param id path int true "User ID"
// @Success 200 {object} HistoryResponse
// @Failure 400 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
// @Router /history/{id} [get]
func (curRoutesHandler RoutesHandler) getHistory(c *fiber.Ctx) error {
	curRoutesHandler.Logger.Log("Trying sending history")
	tmpid := c.Params("id")
	id, err := strconv.Atoi(tmpid)

	if err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{
			Success: false,
			Error:   "ID must be a number",
		})
	}
	isUserReg, err := curRoutesHandler.isUserRegistrated(id)
	if err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{
			Success: false,
			Error:   "DB error: " + err.Error(),
		})
	}

	if !isUserReg {
		curRoutesHandler.Logger.Log("Not registrated user tried to get history")
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{
			Success: false,
			Error:   "User is'n registered",
		})
	}

	curRoutesHandler.Logger.Log(fmt.Sprintf("Trying to find history of user: %v", id))
	rows, err := curRoutesHandler.CurDb.DoQuery("SELECT expression FROM history WHERE id = $1", id)

	if err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{
			Success: false,
			Error:   "DB error: " + err.Error(),
		})
	}

	defer rows.Close()
	curRoutesHandler.Logger.Log(fmt.Sprintf("Successfully found history of user: %v", id))
	curRoutesHandler.Logger.Log("Starting collecting info from DB")
	//collecting data for DB
	var historyMas = []string{}
	for rows.Next() {
		var curExpression string
		if err := rows.Scan(&curExpression); err != nil {
			curRoutesHandler.Logger.Log(err.Error())
			return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{
				Success: false,
				Error:   "Data parsing error: " + err.Error(),
			})
		}

		curRoutesHandler.Logger.Log(fmt.Sprintf("Added expression: %s", curExpression))
		historyMas = append(historyMas, curExpression)
	}

	if err := rows.Err(); err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{
			Success: false,
			Error:   "Rows iteration error",
		})
	}
	curRoutesHandler.Logger.Log(fmt.Sprintf("Sending history to user: %v", id))
	return c.JSON(HistoryResponse{
		Success: true,
		Data:    historyMas,
	})
}

type CalculationRequest struct {
	UserID     int    `json:"user_id"`
	Expression string `json:"expression"`
}

type CalculationResponse struct {
	Success bool    `json:"success"`
	Data    float64 `json:"data,omitempty"`
	Error   string  `json:"error,omitempty"`
}

// @Summary Вычислить выражение
// @Description Вычисляет математическое выражение и сохраняет в историю
// @Tags calculator
// @Accept json
// @Produce json
// @Param request body CalculationRequest true "Данные для вычисления"
// @Success 200 {object} CalculationResponse
// @Failure 400 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
// @Router /calculate [post]
func (curRoutesHandler RoutesHandler) calculateExpression(c *fiber.Ctx) error {
	curRoutesHandler.Logger.Log("Starting reading expression")

	var req CalculationRequest
	if err := c.BodyParser(&req); err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{
			Success: false,
			Error:   "Invalid JSON format: " + err.Error(),
		})
	}

	isUserReg, err := curRoutesHandler.isUserRegistrated(req.UserID)
	if err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{
			Success: false,
			Error:   "DB error: " + err.Error(),
		})
	}

	if !isUserReg {
		curRoutesHandler.Logger.Log("Not registrated user tried to get history")
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{
			Success: false,
			Error:   "User is'n registered",
		})
	}
	curRoutesHandler.Logger.Log(fmt.Sprintf("Trying to calculate expression: %s \nFrom user: %v", req.Expression, req.UserID))
	ansOfExpression, err := calculator.Evaluate(req.Expression)
	if err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{
			Success: false,
			Error:   err.Error(),
		})
	}
	exprValue := fmt.Sprintf("%s=%f", req.Expression, ansOfExpression)
	_, err = curRoutesHandler.CurDb.DoExec(
		"INSERT INTO history (id, expression) VALUES ($1, $2)",
		req.UserID,
		exprValue,
	)
	curRoutesHandler.Logger.Log(fmt.Sprintf("command done: INSERT INTO history (id, expression) VALUES (%v, %s)", req.UserID, exprValue))
	if err != nil {
		curRoutesHandler.Logger.Log(err.Error())
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{
			Success: false,
			Error:   "DB error: " + err.Error(),
		})
	}
	return c.Status(fiber.StatusOK).JSON(CalculationResponse{
		Success: true,
		Data:    ansOfExpression,
	})
}

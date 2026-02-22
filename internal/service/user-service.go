package service

import (
	"backend-go/internal/auth"
	"backend-go/internal/model"
	"backend-go/internal/repository"
	"errors"
	"strconv"

	"golang.org/x/crypto/bcrypt"
)

// UserService defines methods that handlers can call
type UserService interface {
    Register(input model.CreateUserRequest) (*model.User, error)
    GetUserByID(id uint) (*model.User, error)
	Login(email string, password string) (string, error)
}

type userService struct {
    repo repository.UserRepository // Inject repository here
}

func NewUserService(r repository.UserRepository) UserService {
    return &userService{repo: r}
}

func (s *userService) Register(input model.CreateUserRequest) (*model.User, error) {
    // 1. Business logic: check if email already exists
    existingUser, _ := s.repo.FindByEmail(input.Email)
    if existingUser != nil {
        return nil, errors.New("email is already in use")
    }

    // 2. Hash password
    hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)

    user := &model.User{
        Email:    input.Email,
        Password: string(hashedPassword),
        FullName: input.FullName,
    }

    // 3. Call repository to save
    return s.repo.Create(user)
}


func (s *userService) GetUserByID(id uint ) (*model.User, error) {
	return s.repo.FindById(id)
}

func (s *userService) Login(email string, password string) (string, error) {
    user, err := s.repo.FindByEmail(email)
    if err != nil || user == nil {
        return "", errors.New("email or password is incorrect")
    }

    if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
        return "", errors.New("email or password is incorrect")
    }

    token, err := auth.GenerateToken(user.ID, strconv.Itoa(int(user.Role)))
    if err != nil {
        return "", err
    }

    return token, nil
}
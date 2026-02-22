package repository

import (
    "backend-go/internal/model"
    "gorm.io/gorm"
)

type UserRepository interface {
    Create(user *model.User) (*model.User, error)
    FindByEmail(email string) (*model.User, error)
	FindById(id uint)(*model.User, error)
}

type userRepository struct {
    db *gorm.DB 
}

func NewUserRepository(db *gorm.DB) UserRepository {
    return &userRepository{db: db}
}

func (r *userRepository) Create(user *model.User) (*model.User, error) {
    err := r.db.Create(user).Error
    return user, err
}

func (r *userRepository) FindByEmail(email string) (*model.User, error) {
    var user model.User
    err := r.db.Where("email = ?", email).First(&user).Error
    if err != nil {
        return nil, err
    }
    return &user, nil
}

func (r *userRepository) FindById(id uint)(*model.User, error){
	var user model.User
	err := r.db.Where("id = ?", id).First(&user).Error

	if err!=nil{
		return nil, err
	}

	return &user, nil
}

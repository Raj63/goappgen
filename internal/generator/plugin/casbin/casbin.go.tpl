package auth

import (
	"github.com/casbin/casbin/v2"
)

var Enforcer *casbin.Enforcer

func InitRBAC(modelPath, policyPath string) error {
	e, err := casbin.NewEnforcer(modelPath, policyPath)
	if err != nil {
		return err
	}
	Enforcer = e
	return nil
}

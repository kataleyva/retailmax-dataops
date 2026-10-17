"""Entrena el modelo de predicción de ventas con parámetros versionados."""
import json
from sklearn.ensemble import RandomForestRegressor

with open("config/parametros_modelo.json") as f:
    params = json.load(f)

modelo = RandomForestRegressor(
    n_estimators=params["n_estimators"],
    max_depth=params["max_depth"],
    random_state=params["semilla"],
)

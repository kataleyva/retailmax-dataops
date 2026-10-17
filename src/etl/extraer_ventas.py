"""Extrae las ventas diarias del POS y del e-commerce."""
import pandas as pd

def extraer_ventas(ruta: str) -> pd.DataFrame:
    return pd.read_csv(ruta)

"""Limpia y estandariza las ventas de los 5 países."""
import pandas as pd

def limpiar_ventas(df: pd.DataFrame) -> pd.DataFrame:
    df = df.dropna(subset=["id_tienda", "id_producto"])
    df = df[df["unidades"] >= 0]
    df["pais"] = df["pais"].str.upper().str.strip()
    return df

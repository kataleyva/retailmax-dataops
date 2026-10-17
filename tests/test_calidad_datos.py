"""Pruebas de esquema y calidad de datos (C5 d.14)."""
import pandas as pd

def test_esquema_ventas():
    df = pd.read_csv("datos/procesados/ventas.csv")
    assert {"id_tienda", "id_producto", "unidades", "pais"} <= set(df.columns)

def test_unidades_no_negativas():
    df = pd.read_csv("datos/procesados/ventas.csv")
    assert (df["unidades"] >= 0).all()

def test_sin_nulos_en_claves():
    df = pd.read_csv("datos/procesados/ventas.csv")
    assert df[["id_tienda", "id_producto"]].notna().all().all()

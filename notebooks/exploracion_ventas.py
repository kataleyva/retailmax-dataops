# Notebook exportado a .py
# %% Carga de datos
import pandas as pd
df = pd.read_csv("datos/procesados/ventas.csv")
# %% Ventas por país
df.groupby("pais")["total"].sum()

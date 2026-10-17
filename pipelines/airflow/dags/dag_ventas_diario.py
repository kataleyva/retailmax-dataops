from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG("ventas_diario", start_date=datetime(2026, 10, 1),
         schedule="@daily", catchup=False) as dag:
    extraer = BashOperator(task_id="extraer", bash_command="python src/etl/extraer_ventas.py")
    validar = BashOperator(task_id="validar_calidad", bash_command="pytest tests/test_calidad_datos.py")
    transformar = BashOperator(task_id="transformar", bash_command="python src/etl/transformar_ventas.py")
    extraer >> validar >> transformar

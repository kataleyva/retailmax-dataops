# RetailMax DataOps

Repositorio del pipeline de datos y del modelo de predicción de ventas de RetailMax (5 países de Latinoamérica). Su objetivo es que cualquier resultado (modelo, dashboard o análisis) se pueda recrear en cualquier momento a través de comandos.

## Qué se versiona

| Tipo | Ubicación | Ejemplos |
|---|---|---|
| Código | `src/`, `notebooks/`, `sql/consultas/` | Scripts de Python, notebooks exportados a .py (sin salidas), consultas SQL |
| Migraciones de esquema | `sql/migraciones/` | `V001__create_usuarios_table.sql` (Flyway) |
| Configuraciones | `config/`, `requirements.txt` | YAML por entorno, parámetros del modelo en JSON, dependencias con versión fija |
| Definiciones de pipeline | `pipelines/` | DAG de Airflow, Jenkinsfile |
| Infraestructura | `infraestructura/` | Terraform con un archivo `.tfvars` por entorno, Dockerfile |
| Pruebas | `tests/` | Pruebas de esquema y calidad de datos |
| Documentación | `docs/` | Procedencia de datos y diagramas |

## Qué no se versiona y por qué

| No se versiona | Por qué | Dónde vive |
|---|---|---|
| Datos crudos y procesados (`datos/`) | Git no está diseñado para archivos grandes: un repositorio de 50 GB es inviable. Además contienen datos personales de clientes | Almacenamiento remoto (S3), versionado con DVC |
| Credenciales y secretos (`.env`, `.pem`) | Cualquiera con acceso al repositorio podría ver las contraseñas de producción | Gestor de secretos y variables de entorno |
| Modelos entrenados (`.pkl`, `.onnx`) | Son pesados y se regeneran desde código, datos y parámetros versionados | Registro de modelos (MLflow) |
| Estado de Terraform (`.tfstate`) | Contiene información sensible de la infraestructura | Backend remoto de Terraform |
| Entornos y temporales (`venv/`, `__pycache__/`) | Se recrean con `requirements.txt` y dependen de cada máquina | No se guardan |

Estas exclusiones están definidas en `.gitignore`.

## Versionado de la procedencia de los datos

Los datos no se guardan en Git. Lo que se versiona es su **procedencia**: de dónde vienen, cuándo se extrajeron, qué transformaciones tuvieron y qué versión exacta se usó.

1. **DVC:** cada dataset tiene un archivo `.dvc` en Git con un hash (identificador único). Los datos reales están en S3.
   ```bash
   dvc add datos/raw/ventas_2026-09.csv
   git add datos/raw/ventas_2026-09.csv.dvc
   git commit -m "Agrega versión de ventas de septiembre"
   ```
   Para recuperar los datos de cualquier versión: `git checkout <commit>` y luego `dvc pull`.
2. **Registro de procedencia:** `docs/procedencia_datos.md` documenta la fuente, la fecha, el hash, las transformaciones y el responsable de cada dataset.
3. **Parámetros del modelo:** `config/parametros_modelo.json` guarda la versión de los datos de entrenamiento y la semilla, para recrear el modelo exacto.
4. **Esquemas:** los cambios de estructura de las tablas se versionan como migraciones en `sql/migraciones/`.
5. **Snapshots:** la tabla maestra de clientes tiene snapshots diarios para reproducir análisis históricos.

## Cómo reproducir un resultado

```bash
git checkout <commit-o-tag>
dvc pull
docker build -t retailmax -f infraestructura/docker/Dockerfile .
python src/modelos/entrenar_modelo_ventas.py
```
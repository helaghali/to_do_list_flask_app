# Flask Starter Project


Quick start (Windows):

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
set FLASK_APP=run.py
set FLASK_ENV=development
flask run
```
Quick start (Linux/wsl):

```python3 -m venv .venv-wsl
source .venv-wsl/bin/activate

# install deps
pip install -r requirements.txt

# run the app
python run.py
```

Todo app quick steps (initialize DB then run):

```bash
python init_db.py
python run.py
```

Open http://localhost:5000/tasks to view the Todo list.

Docker
------

Build the Docker image from the project root (works in WSL or native Docker):

```bash
docker build -t flask-todo:latest .
```

Run the container and publish port 5000 to the host:

```bash
# ephemeral container (no DB persistence)
docker run --rm -p 5000:5000 flask-todo:latest
```

If you want the SQLite database to persist on the host, mount the `instance` folder:

```bash
# create local instance folder if it doesn't exist
mkdir -p instance

# run with volume mount (host ./instance <-> container /app/instance)
docker run --rm -p 5000:5000 -v $(pwd)/instance:/app/instance flask-todo:latest
```

Notes:
- The container uses `gunicorn` to serve the app on port 5000.
- If the DB file is not present in `instance/`, it will be created on first run (or run `python init_db.py` inside the container to pre-create it).


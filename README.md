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
